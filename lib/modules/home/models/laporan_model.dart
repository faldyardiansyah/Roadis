import 'dart:ui';
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
  final String? wilayahNama;

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
    this.wilayahNama,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    String? wilayahNama;

    final wilayah = json['wilayah'];

    if (wilayah is Map<String, dynamic>) {
      final nama = wilayah['nama'] ?? wilayah['name'];

      if (nama != null) {
        wilayahNama = nama.toString();
      }
    }

    return LaporanModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      image: json['image']?.toString() ?? '',
      tipeKerusakan: json['tipe_kerusakan']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      waktuLaporan: json['waktu_laporan']?.toString() ?? '',
      wilayahNama: wilayahNama,
    );
  }
}

extension LaporanStatusX on String {
  String get statusLabel {
    switch (toLowerCase()) {
      case 'menunggu':
        return 'Menunggu';
      case 'proses':
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