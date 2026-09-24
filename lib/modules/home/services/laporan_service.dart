import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:roadis/core/api_config.dart';
import 'package:roadis/auth/services/session_storage.dart';
import '../models/laporan_model.dart';

class LaporanException implements Exception {
  final String message;
  LaporanException(this.message);
  @override
  String toString() => message;
}

class LaporanService {
  Future<List<LaporanModel>> getRiwayat() async {
    final body = await _get('/warga/laporan/riwayat');
    return _parseList(body);
  }

  Future<List<LaporanModel>> getPeta() async {
    final body = await _get('/warga/laporan/peta');
    return _parseList(body);
  }

  List<LaporanModel> _parseList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data == null) return [];
    return (data as List)
        .map((e) => LaporanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final token = SessionStorage.getToken();

    try {
      final res = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return body;
      throw LaporanException(
        body['error']?.toString() ?? body['message']?.toString() ?? 'Gagal mengambil data',
      );
    } on SocketException {
      throw LaporanException('Tidak bisa terhubung ke server');
    } on http.ClientException {
      throw LaporanException('Tidak bisa terhubung ke server');
    } on TimeoutException {
      throw LaporanException('Koneksi timeout, coba lagi');
    } on FormatException {
      throw LaporanException('Respons server tidak valid');
    }
  }
}