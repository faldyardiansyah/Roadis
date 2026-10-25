import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:roadis/auth/services/session_storage.dart';
import 'package:roadis/core/api_config.dart';
import 'package:roadis/core/detection/models/detection_result.dart';
import 'package:roadis/core/laporan/models/wilayah_model.dart';
import 'package:camera/camera.dart';

class ReportFormController extends GetxController {
  // data dari kamera
  late XFile image;
  late Position position;
  DetectionResult? detection;
  List<WilayahModel> wilayahList = [];

  // controller buat input form
  late final TextEditingController judulController;
  late final TextEditingController deskripsiController;

  // titik asli gps dan titik pin yang dipilih
  late final LatLng gpsPoint;
  final pickedPoint = Rxn<LatLng>();
  final MapController mapController = MapController();
  final Distance distance = const Distance();

  // jam saat laporan dibuat
  final DateTime waktu = DateTime.now();

  // status proses biar tombol dan kartu bisa menampilkan loading
  final isSubmitting = false.obs;
  final isCheckingRoad = false.obs;

  // data pilihan di form
  final selectedType = Rxn<String>();
  final selectedWilayahId = Rxn<int>();

  // hasil pemeriksaan jalan dari osm
  final roadDetected = Rxn<bool>();
  final jarakJalanOSM = Rxn<double>();
  final namaJalanOSM = Rxn<String>();
  final jenisJalanOSM = Rxn<String>();
  final kewenanganOSM = Rxn<String>();
  final penjelasanKewenangan = Rxn<String>();
  final roadCheckError = Rxn<String>();
  int _roadCheckSeq = 0; // penanda pengecekan terbaru

  // daftar jenis kerusakan
  final List<String> jenisKerusakan = [
    'Retak Buaya',
    'Retak Tepi',
    'Retak Memanjang',
    'Tambalan',
    'Lubang Jalan',
    'Jalan Bergelombang',
    'Retak Melintang',
  ];

  static const double maxShiftMeters = 1000;

  // pagi sampai siang (06:00-14:59) = ai paling bagus
  bool get isGoodTime => waktu.hour >= 6 && waktu.hour < 15;

  // sore (15:00-17:59) = mulai kurang bagus
  bool get isEvening => waktu.hour >= 15 && waktu.hour < 18;

  // format jam biar dua digit
  String _two(int n) => n.toString().padLeft(2, '0');

  String get jamText => '${_two(waktu.hour)}:${_two(waktu.minute)}';

  String get tanggalText =>
      '${_two(waktu.day)}/${_two(waktu.month)}/${waktu.year}';

  // siapkan data awal saat form dibuka
  void initialize({
    required XFile image,
    required Position position,
    required DetectionResult? detection,
    required List<WilayahModel> wilayahList,
  }) {
    this.image = image;
    this.position = position;
    this.detection = detection;
    this.wilayahList = wilayahList;

    gpsPoint = LatLng(position.latitude, position.longitude);
    pickedPoint.value = gpsPoint;

    // isi otomatis kalau ai yakin dan waktu masih bagus
    final confident =
        detection != null && detection.confidence >= 0.8 && isGoodTime;
    final name = confident ? detection.displayName : null;

    selectedType.value = name;
    judulController.text = name != null ? 'Kerusakan $name' : '';
    deskripsiController.text = name != null
        ? 'Ditemukan $name pada jalan.'
        : '';

    // cari wilayah dan periksa jalan dari titik gps
    detectWilayah(gpsPoint);
    checkRoad(gpsPoint);
  }

  @override
  void onInit() {
    super.onInit();
    judulController = TextEditingController();
    deskripsiController = TextEditingController();
  }

  // buang kata kabupaten/kota/dll biar nama gampang dicocokin
  String _norm(String s) => s
      .toLowerCase()
      .replaceAll(
        RegExp(r'kabupaten|kab\.|kota|kecamatan|kec\.|kelurahan|desa'),
        '',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // cari nama wilayah dari koordinat, lalu cocokin ke daftar wilayah
  Future<void> detectWilayah(LatLng point) async {
    if (wilayahList.isEmpty) return;

    try {
      final marks = await geo.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (marks.isEmpty) return;

      final m = marks.first;
      final candidates = [
        m.subLocality,
        m.locality,
        m.subAdministrativeArea,
        m.administrativeArea,
      ].whereType<String>().map(_norm).where((e) => e.isNotEmpty).toList();

      debugPrint('Geocode: $candidates'); // lihat ini buat nyocokin nama

      for (final w in wilayahList) {
        final name = _norm(w.nama);
        if (name.isEmpty) continue;

        if (candidates.any((c) => c.contains(name) || name.contains(c))) {
          selectedWilayahId.value = w.id;
          return;
        }
      }
    } catch (e) {
      debugPrint('Gagal deteksi wilayah: $e');
    }
  }

  // kalau titik di luar zona, tempel ke tepi lingkaran
  LatLng clampToZone(LatLng point) {
    final d = distance.distance(gpsPoint, point);
    if (d <= maxShiftMeters) return point;

    final bearing = distance.bearing(gpsPoint, point);
    return distance.offset(gpsPoint, maxShiftMeters, bearing);
  }

  // pin pindah ke titik yang diketuk (maksimal di tepi zona)
  void onMapTap(LatLng point) {
    final clamped = clampToZone(point);
    pickedPoint.value = clamped;

    // periksa ulang wilayah dan jalan di titik pin
    detectWilayah(clamped);
    checkRoad(clamped);
  }

  // balikin pin ke titik gps
  void resetPoint() {
    pickedPoint.value = gpsPoint;
    mapController.move(gpsPoint, 20);
    detectWilayah(gpsPoint);
    checkRoad(gpsPoint);
  }

  // Periksa jalan terdekat melalui API backend.
  Future<void> checkRoad(LatLng point) async {
    final seq = ++_roadCheckSeq;

    isCheckingRoad.value = true;
    roadCheckError.value = null;

    // Bersihkan hasil pemeriksaan sebelumnya.
    roadDetected.value = null;
    namaJalanOSM.value = null;
    jenisJalanOSM.value = null;
    jarakJalanOSM.value = null;
    kewenanganOSM.value = null;
    penjelasanKewenangan.value = null;

    try {
      final token = SessionStorage.getToken()?.trim();

      final uri = Uri.parse('${ApiConfig.baseUrl}/warga/cek-jalan').replace(
        queryParameters: {
          'latitude': point.latitude.toString(),
          'longitude': point.longitude.toString(),
        },
      );

      final headers = <String, String>{'Accept': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('CEK JALAN #$seq REQUEST: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      // Abaikan respons dari pemeriksaan yang sudah lama.
      if (seq != _roadCheckSeq) return;

      debugPrint(
        'CEK JALAN #$seq HTTP ${response.statusCode}: '
        '${response.body}',
      );

      dynamic body;

      try {
        body = jsonDecode(response.body);
      } catch (_) {
        throw Exception(
          'Respons server bukan JSON '
          '(HTTP ${response.statusCode}).',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = body is Map ? body['message']?.toString() : null;

        throw Exception(message ?? 'HTTP ${response.statusCode}');
      }

      if (body is! Map || body['data'] is! Map) {
        throw Exception('Format respons API tidak sesuai.');
      }

      final data = Map<String, dynamic>.from(body['data'] as Map);

      final detected = data['terdeteksi'] == true;

      roadDetected.value = detected;
      penjelasanKewenangan.value = data['keterangan']?.toString();

      if (!detected) {
        roadCheckError.value = null;
        penjelasanKewenangan.value =
            'Jalan tidak ditemukan di sekitar titik GPS. '
            'Coba pilih titik yang lebih dekat ke badan jalan.';
        return;
      }

      namaJalanOSM.value = data['nama_jalan']?.toString();

      jenisJalanOSM.value = data['jenis_jalan']?.toString() ?? 'belum_pasti';

      final jarak = data['jarak_meter'];

      jarakJalanOSM.value = jarak is num
          ? jarak.toDouble()
          : double.tryParse(jarak?.toString() ?? '');

      // Jenis highway OSM bukan bukti kewenangan resmi.
      final highway = (jenisJalanOSM.value ?? '').trim().toLowerCase();

      switch (highway) {
        case 'motorway':
        case 'motorway_link':
        case 'trunk':
        case 'trunk_link':
          kewenanganOSM.value = 'Perkiraan jalan nasional — perlu verifikasi';
          penjelasanKewenangan.value =
              'Tipe jalan dari OpenStreetMap mengarah pada '
              'kelas jalan utama. Status kewenangan resminya '
              'tetap perlu diverifikasi.';
          break;

        case 'primary':
        case 'primary_link':
        case 'secondary':
        case 'secondary_link':
        case 'tertiary':
        case 'tertiary_link':
          kewenanganOSM.value = 'Belum dapat dipastikan';
          penjelasanKewenangan.value =
              'Jenis jalan berhasil ditemukan, tetapi '
              'penanggung jawab belum dapat dipastikan '
              'dari tipe OpenStreetMap saja.';
          break;

        case 'residential':
          kewenanganOSM.value = 'Belum terverifikasi — kemungkinan jalan lokal';
          penjelasanKewenangan.value =
              'Residential berarti jalan permukiman. '
              'Penanggung jawabnya bisa pemerintah desa '
              'atau instansi lain dan perlu diverifikasi.';
          break;

        case 'living_street':
        case 'unclassified':
        case 'service':
        case 'road':
          kewenanganOSM.value = 'Belum dapat dipastikan';
          penjelasanKewenangan.value =
              'Tipe jalan sudah ditemukan, tetapi instansi '
              'penanggung jawab masih perlu diperiksa.';
          break;

        default:
          kewenanganOSM.value = 'Menunggu verifikasi superadmin';
          penjelasanKewenangan.value =
              'Data tipe jalan belum cukup untuk menentukan '
              'instansi penanggung jawab. Mohon menunggu '
              'verifikasi superadmin.';
      }
    } on TimeoutException {
      if (seq != _roadCheckSeq) return;

      roadDetected.value = null;
      roadCheckError.value =
          'Server terlalu lama merespons. '
          'Silakan periksa ulang beberapa saat lagi.';
    } on SocketException {
      if (seq != _roadCheckSeq) return;

      roadDetected.value = null;
      roadCheckError.value =
          'Tidak dapat terhubung ke server. '
          'Periksa koneksi jaringan Anda.';
    } catch (e) {
      if (seq != _roadCheckSeq) return;

      roadDetected.value = null;
      roadCheckError.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('GAGAL CEK JALAN: $e');
    } finally {
      if (seq == _roadCheckSeq) {
        isCheckingRoad.value = false;
      }
    }
  }

  // kirim laporan (sementara masih simulasi, belum upload ke api)
  Future<Map<String, dynamic>?> submitReport() async {
    if (selectedWilayahId.value == null) {
      return null;
    }

    isSubmitting.value = true;

    try {
      final point = pickedPoint.value ?? gpsPoint;

      final reportData = {
        'judul': judulController.text.trim(),
        'deskripsi': deskripsiController.text.trim(),
        'tipe_kerusakan': selectedType.value,
        'wilayah_id': selectedWilayahId.value,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'gps_latitude': position.latitude,
        'gps_longitude': position.longitude,
        'lokasi_digeser': distance.distance(gpsPoint, point) > 0.5,
        'waktu_laporan': waktu.toIso8601String(),
        'image_path': image.path,
        'ai_class': detection?.className,
        'ai_confidence': detection?.confidence,
      };

      debugPrint('DATA LAPORAN: $reportData');

      // TODO: hubungkan ke api upload laporan supaya tersimpan ke database
      await Future.delayed(const Duration(milliseconds: 500));

      return reportData;
    } catch (e) {
      debugPrint('Gagal kirim laporan: $e');
      rethrow;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    judulController.dispose();
    deskripsiController.dispose();
    mapController.dispose();
    super.onClose();
  }
}
