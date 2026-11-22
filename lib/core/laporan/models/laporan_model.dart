import 'package:flutter/material.dart';
import 'package:roadis/utils/app_colors.dart';

class LaporanModel {
  final int id;
  final int userId;
  final String judul;
  final String deskripsi;
  final double latitude;
  final double longitude;
  final String image;
  final String tipeKerusakan;
  final String status;
  final String waktuLaporan;
  final String fotoBukti;
  final String catatanAdmin;
  final String? wilayahNama;
  final String? namaPelapor;
  final String? jenisJalan;
  final String? kewenanganJalan;
  final String? severity;

  LaporanModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.deskripsi,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.tipeKerusakan,
    required this.status,
    required this.waktuLaporan,
    required this.fotoBukti,
    required this.catatanAdmin,
    this.wilayahNama,
    this.namaPelapor,
    this.jenisJalan,
    this.kewenanganJalan,
    this.severity,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    String? wilayahNama;
    final wilayah = json['wilayah'];

    if (wilayah is Map) {
      final nama = wilayah['nama'] ?? wilayah['name'];
      if (nama != null) {
        wilayahNama = nama.toString();
      }
    }

    // Fallback jika backend mengirim nama wilayah secara langsung.
    wilayahNama ??= json['wilayah_nama']?.toString();

    String? namaPelapor;
    final user = json['user'];

    if (user is Map) {
      final nama = user['name'] ?? user['nama'];
      if (nama != null) {
        namaPelapor = nama.toString();
      }
    }

    final jenisJalan =
        (json['jenis_jalan'] ?? json['road_type'] ?? json['jenis_jalan_osm'])
            ?.toString();

    String? kewenanganJalan =
        (json['kewenangan_jalan'] ??
                json['kewenangan'] ??
                json['penanggung_jawab'])
            ?.toString();

    // Jika kewenanganJalan belum terisi langsung dari backend,
    // turunkan dari jenis_jalan (contoh: 'desa', 'kabupaten', 'provinsi', 'nasional')
    if (kewenanganJalan == null ||
        kewenanganJalan.trim().isEmpty ||
        kewenanganJalan == 'belum_pasti' ||
        kewenanganJalan == 'belum diketahui') {
      if (jenisJalan != null &&
          jenisJalan.trim().isNotEmpty &&
          jenisJalan != 'belum_pasti') {
        switch (jenisJalan.toLowerCase().trim()) {
          case 'desa':
            kewenanganJalan = 'Pemerintah Desa (Pemdes)';
            break;
          case 'kabupaten':
            kewenanganJalan = 'Pemerintah Kabupaten (Kab. Indramayu)';
            break;
          case 'provinsi':
            kewenanganJalan = 'Pemerintah Provinsi (Provinsi Jawa Barat)';
            break;
          case 'nasional':
            kewenanganJalan = 'Pemerintah Pusat (Nasional RI / PUPR)';
            break;
          case 'residential':
          case 'living_street':
          case 'unclassified':
          case 'service':
          case 'track':
            kewenanganJalan = 'Pemerintah Desa (Pemdes)';
            break;
          case 'tertiary':
          case 'tertiary_link':
          case 'secondary':
          case 'secondary_link':
            kewenanganJalan = 'Pemerintah Kabupaten (Kab. Indramayu)';
            break;
          case 'primary':
          case 'primary_link':
            kewenanganJalan = 'Pemerintah Provinsi (Provinsi Jawa Barat)';
            break;
          case 'trunk':
          case 'trunk_link':
          case 'motorway':
          case 'motorway_link':
            kewenanganJalan = 'Pemerintah Pusat (Nasional RI / PUPR)';
            break;
        }
      }
    }

    return LaporanModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      image: (json['image_url'] ?? json['image'])?.toString() ?? '',
      tipeKerusakan: json['tipe_kerusakan']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      waktuLaporan:
          json['created_at']?.toString() ??
          json['waktu_laporan']?.toString() ??
          '',
      fotoBukti: json['foto_bukti']?.toString() ?? '',
      catatanAdmin: json['catatan_admin']?.toString() ?? '',
      wilayahNama: wilayahNama,
      namaPelapor: namaPelapor,
      jenisJalan: jenisJalan,
      kewenanganJalan: kewenanganJalan,
      severity: json['severity']?.toString(),
    );
  }
}

extension LaporanStatusX on String {
  String get statusLabel {
    switch (toLowerCase()) {
      case 'menunggu':
        return 'Menunggu';
      case 'proses':
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return this;
    }
  }

  Color get statusColor {
    switch (toLowerCase()) {
      case 'menunggu':
        return AppColors.greyColor;
      case 'proses':
      case 'diproses':
        return AppColors.yellowColor;
      case 'selesai':
        return AppColors.greenColor;
      case 'ditolak':
        return AppColors.redColor;
      default:
        return AppColors.primaryColor;
    }
  }
}