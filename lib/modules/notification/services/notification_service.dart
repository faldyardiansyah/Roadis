
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:roadis/core/api_config.dart';
import 'package:roadis/auth/services/session_storage.dart';

class NotificationException implements Exception {
  final String message;

  NotificationException(this.message);

  @override
  String toString() => message;
}

class NotificationService {
  Map<String, String> _headers() {
    final token = SessionStorage.getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = _headers();

      late http.Response response;

      if (method == 'GET') {
        response = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      } else if (method == 'PUT') {
        response = await http
            .put(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      } else if (method == 'DELETE') {
        response = await http
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      } else {
        throw NotificationException('Metode request tidak didukung');
      }

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw NotificationException('Format respons server tidak sesuai');
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return decoded;
      }

      throw NotificationException(
        decoded['error']?.toString() ??
            decoded['message']?.toString() ??
            'Gagal mengakses notifikasi (${response.statusCode})',
      );
    } on SocketException {
      throw NotificationException('Tidak bisa terhubung ke server');
    } on http.ClientException {
      throw NotificationException('Tidak bisa terhubung ke server');
    } on TimeoutException {
      throw NotificationException('Koneksi timeout, coba lagi');
    } on FormatException {
      throw NotificationException('Respons server bukan JSON yang valid');
    }
  }

  // Mengambil daftar notifikasi pengguna.
  Future<List<Map<String, dynamic>>> getNotifikasi() async {
    final body = await _request('GET', '/notifikasi');
    final data = body['data'];

    if (data == null) return [];

    if (data is! List) {
      throw NotificationException(
        'Data notifikasi dari server tidak berbentuk list',
      );
    }

    return data
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  // Menandai satu notifikasi sebagai dibaca.
  Future<void> tandaiDibaca(int id) async {
    await _request('PUT', '/notifikasi/$id/read');
  }

  // Menandai semua notifikasi sebagai dibaca.
  Future<void> tandaiSemuaDibaca() async {
    await _request('PUT', '/notifikasi/read-all');
  }

  // Menghapus satu notifikasi.
  Future<void> hapusNotifikasi(int id) async {
    await _request('DELETE', '/notifikasi/$id');
  }
}
