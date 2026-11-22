import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  late XFile image;
  late Position position;
  DetectionResult? detection;
  List<WilayahModel> wilayahList = [];

  late final TextEditingController judulController;
  late final TextEditingController deskripsiController;

  late final LatLng gpsPoint;
  final pickedPoint = Rxn<LatLng>();
  final MapController mapController = MapController();
  final Distance distance = const Distance();

  final DateTime waktu = DateTime.now();

  final isSubmitting = false.obs;
  final isCheckingRoad = false.obs;
  final isUsingGroq = false.obs;

  final selectedType = Rxn<String>();
  final selectedWilayahId = Rxn<int>();

  final roadDetected = Rxn<bool>();
  final jarakJalanOSM = Rxn<double>();
  final namaJalanOSM = Rxn<String>();
  final jenisJalanOSM = Rxn<String>();
  final kewenanganOSM = Rxn<String>();
  final penjelasanKewenangan = Rxn<String>();
  final roadCheckError = Rxn<String>();
  int _roadCheckSeq = 0;

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

  bool get isGoodTime => waktu.hour >= 6 && waktu.hour < 15;

  bool get isEvening => waktu.hour >= 15 && waktu.hour < 18;

  String _two(int n) => n.toString().padLeft(2, '0');

  String get jamText => '${_two(waktu.hour)}:${_two(waktu.minute)}';

  String get tanggalText =>
      '${_two(waktu.day)}/${_two(waktu.month)}/${waktu.year}';

  void initialize({
    required XFile image,
    required Position position,
    required DetectionResult? detection,
    required List<WilayahModel> wilayahList,
    bool isUsingGroq = false,
  }) {
    this.image = image;
    this.position = position;
    this.detection = detection;
    this.wilayahList = wilayahList;
    this.isUsingGroq.value = isUsingGroq;

    gpsPoint = LatLng(position.latitude, position.longitude);
    pickedPoint.value = gpsPoint;

    final confident = detection != null && detection.confidence >= 0.8;
    final name = confident ? detection.displayName : null;

    selectedType.value = name;

    if (name != null) {
      judulController.text = 'Laporan Kerusakan $name';
      deskripsiController.text =
          'Ditemukan kondisi kerusakan jalan berupa $name dengan tingkat keyakinan AI ${(detection!.confidence * 100).toStringAsFixed(1)}%. Mohon tindak lanjut dari pihak terkait.';
    } else {
      judulController.text = '';
      deskripsiController.text = '';
    }

    detectWilayah(gpsPoint);
    checkRoad(gpsPoint);
  }

  @override
  void onInit() {
    super.onInit();
    judulController = TextEditingController();
    deskripsiController = TextEditingController();
  }

  @override
  void onClose() {
    judulController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  String _norm(String s) => s
      .toLowerCase()
      .replaceAll(
        RegExp(r'kabupaten|kab\.|kota|kecamatan|kec\.|kelurahan|desa'),
        '',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  void updateImage(XFile newImage) {
    image = newImage;
  }

  void updateDetection(DetectionResult? newDetection) {
    detection = newDetection;

    if (newDetection != null && newDetection.confidence >= 0.8) {
      final name = newDetection.displayName;

      selectedType.value = name;
      judulController.text = 'Laporan Kerusakan $name';
      deskripsiController.text =
          'Ditemukan kondisi kerusakan jalan berupa $name dengan tingkat keyakinan AI ${(newDetection.confidence * 100).toStringAsFixed(1)}%. Mohon tindak lanjut dari pihak terkait.';
    } else {
      selectedType.value = newDetection?.displayName;
      judulController.clear();
      deskripsiController.clear();
    }
  }

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

      debugPrint('Geocode: $candidates');

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

  LatLng clampToZone(LatLng point) {
    final d = distance.distance(gpsPoint, point);
    if (d <= maxShiftMeters) return point;

    final bearing = distance.bearing(gpsPoint, point);
    return distance.offset(gpsPoint, maxShiftMeters, bearing);
  }

  void onMapTap(LatLng point) {
    final clamped = clampToZone(point);
    pickedPoint.value = clamped;

    detectWilayah(clamped);
    checkRoad(clamped);
  }

  void resetPoint() {
    pickedPoint.value = gpsPoint;
    mapController.move(gpsPoint, 20);
    detectWilayah(gpsPoint);
    checkRoad(gpsPoint);
  }

  Future<void> checkRoad(LatLng point) async {
    final seq = ++_roadCheckSeq;

    isCheckingRoad.value = true;
    roadCheckError.value = null;

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

      if (seq != _roadCheckSeq) return;

      debugPrint(
        'CEK JALAN #$seq HTTP ${response.statusCode}: ${response.body}',
      );

      dynamic body;

      try {
        body = jsonDecode(response.body);
      } catch (_) {
        throw Exception(
          'Respons server bukan JSON (HTTP ${response.statusCode}).',
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

      final highway = (jenisJalanOSM.value ?? '').trim().toLowerCase();

      switch (highway) {
        case 'motorway':
        case 'motorway_link':
        case 'trunk':
        case 'trunk_link':
        case 'nasional':
          kewenanganOSM.value = 'Pemerintah Pusat (Nasional RI / PUPR)';
          penjelasanKewenangan.value = 'Ruas jalan nasional kewenangan Pemerintah Pusat / Kementerian PUPR RI. Di tingkat lokal, laporan tetap dimonitor dan diteruskan oleh Dinas PU Kab. Indramayu.';
          break;

        case 'primary':
        case 'primary_link':
        case 'provinsi':
          kewenanganOSM.value = 'Pemerintah Provinsi (Jawa Barat)';
          penjelasanKewenangan.value = 'Ruas jalan provinsi kewenangan Dinas Bina Marga Provinsi Jawa Barat. Di tingkat lokal, laporan tetap dimonitor dan dikoordinasikan oleh Dinas PU Kab. Indramayu.';
          break;

        case 'secondary':
        case 'secondary_link':
        case 'tertiary':
        case 'tertiary_link':
        case 'kabupaten':
          kewenanganOSM.value = 'Pemerintah Kabupaten (Kab. Indramayu)';
          penjelasanKewenangan.value = 'Ruas jalan kabupaten di bawah kewenangan teknis Dinas Pekerjaan Umum (DPUPR) Kabupaten Indramayu.';
          break;

        case 'residential':
        case 'living_street':
        case 'unclassified':
        case 'service':
        case 'road':
        case 'track':
        case 'path':
        case 'desa':
          kewenanganOSM.value = 'Pemerintah Desa (Pemdes)';
          penjelasanKewenangan.value = 'Ruas jalan lingkungan/permukiman desa di bawah kewenangan Pemerintah Desa setempat.';
          break;

        default:
          kewenanganOSM.value = 'Belum dapat dipastikan';
          penjelasanKewenangan.value = 'Tipe jalan berhasil ditemukan dari OpenStreetMap, instansi penanggung jawab resmi akan diverifikasi oleh admin.';
      }
    } on TimeoutException {
      if (seq != _roadCheckSeq) return;

      roadDetected.value = null;
      roadCheckError.value = 'Server terlalu lama merespons. Silakan periksa ulang beberapa saat lagi.';
    } on SocketException {
      if (seq != _roadCheckSeq) return;

      roadDetected.value = null;
      roadCheckError.value =
          'Tidak dapat terhubung ke server. Periksa koneksi jaringan Anda.';
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

  Future<Map<String, dynamic>?> submitReport() async {
    if (isSubmitting.value) return null;

    final token = SessionStorage.getToken()?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi login kamu sudah berakhir. Silakan login kembali.');
    }

    final wilayahId = selectedWilayahId.value;

    if (wilayahId == null) {
      throw Exception('Silakan pilih wilayah tempat kerusakan ditemukan.');
    }

    final judul = judulController.text.trim();
    final deskripsi = deskripsiController.text.trim();
    final tipe = selectedType.value?.trim();

    if (judul.isEmpty) {
      throw Exception('Judul laporan belum diisi.');
    }

    if (deskripsi.isEmpty) {
      throw Exception('Deskripsi laporan belum diisi.');
    }

    if (tipe == null || tipe.isEmpty) {
      throw Exception('Silakan pilih jenis kerusakan jalan.');
    }

    if (await image.length() == 0) {
      throw Exception('Foto laporan kosong. Silakan ambil foto kembali.');
    }

    isSubmitting.value = true;

    try {
      final point = pickedPoint.value ?? gpsPoint;
      final uri = Uri.parse('${ApiConfig.baseUrl}/warga/laporan');

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'judul': judul,
        'deskripsi': deskripsi,
        'tipe_kerusakan': tipe,
        'wilayah_id': wilayahId.toString(),
        'latitude': point.latitude.toString(),
        'longitude': point.longitude.toString(),
        'severity': 'belum_dinilai',
      });

      if (detection != null) {
        request.fields['ai_model'] =
            isUsingGroq.value ? 'groq_qwen3.8-27b' : 'yolov11';
        request.fields['ai_confidence'] =
            detection!.confidence.toStringAsFixed(4);
        request.fields['ai_label'] = detection!.displayName;
      }

      request.files.add(await http.MultipartFile.fromPath('foto', image.path));

      debugPrint('KIRIM LAPORAN: $uri');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('STATUS LAPORAN: ${response.statusCode}');
      debugPrint('RESPONS LAPORAN: ${response.body}');

      dynamic body;

      try {
        body = jsonDecode(response.body);
      } catch (_) {
        throw Exception(
          'Server memberikan respons yang belum bisa dibaca. '
          'Silakan coba beberapa saat lagi.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = body is Map ? body['message']?.toString() : null;

        throw Exception(
          message ?? 'Laporan belum berhasil dikirim. Silakan coba lagi.',
        );
      }

      if (body is! Map || body['status'] != 'success') {
        final message = body is Map ? body['message']?.toString() : null;

        throw Exception(
          message ?? 'Laporan belum dikonfirmasi berhasil oleh server.',
        );
      }

      final data = body['data'];

      if (data is! Map) {
        throw Exception('Data laporan tidak ditemukan dalam respons server.');
      }

      return Map<String, dynamic>.from(data);
    } on TimeoutException {
      throw Exception(
        'Pengiriman membutuhkan waktu terlalu lama. '
        'Periksa riwayat laporan sebelum mencoba mengirim ulang.',
      );
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.',
      );
    } catch (e) {
      debugPrint('GAGAL KIRIM LAPORAN: $e');
      rethrow;
    } finally {
      isSubmitting.value = false;
    }
  }
}
