import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:roadis/core/api_config.dart';
import 'package:roadis/auth/services/session_storage.dart';

import '../models/chat_message_model.dart';

class ChatException implements Exception {
  final String message;

  ChatException(this.message);

  @override
  String toString() => message;
}

class ChatService {
  Map<String, String> _headers() {
    final token = SessionStorage.getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = _headers();

      late http.Response response;

      if (method == 'GET') {
        response = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      } else if (method == 'POST') {
        response = await http
            .post(uri, headers: headers, body: jsonEncode(data ?? {}))
            .timeout(const Duration(seconds: 15));
      } else if (method == 'PUT') {
        response = await http
            .put(uri, headers: headers, body: jsonEncode(data ?? {}))
            .timeout(const Duration(seconds: 15));
      } else {
        throw ChatException('Metode request tidak didukung');
      }

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw ChatException('Format respons server tidak sesuai');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }

      throw ChatException(
        decoded['error']?.toString() ??
            decoded['message']?.toString() ??
            'Gagal mengakses chat (${response.statusCode})',
      );
    } on SocketException {
      throw ChatException('Tidak bisa terhubung ke server');
    } on http.ClientException {
      throw ChatException('Tidak bisa terhubung ke server');
    } on TimeoutException {
      throw ChatException('Koneksi timeout, coba lagi');
    } on FormatException {
      throw ChatException('Respons server bukan JSON yang valid');
    }
  }

  List<ChatMessageModel> _parseMessages(Map<String, dynamic> body) {
    final data = body['data'];

    if (data == null) return [];

    if (data is! List) {
      throw ChatException('Data chat dari server tidak berbentuk list');
    }

    return data
        .map(
          (item) =>
              ChatMessageModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  // Warga: melihat chat pada laporan tertentu.
  Future<List<ChatMessageModel>> getChatWarga(int laporanId) async {
    final body = await _request('GET', '/warga/laporan/$laporanId/chat');

    return _parseMessages(body);
  }

  // Warga: mengirim pesan pada laporan tertentu.
  Future<void> kirimPesanWarga({
    required int laporanId,
    required String pesan,
  }) async {
    await _request(
      'POST',
      '/warga/laporan/$laporanId/chat',
      data: {'pesan': pesan},
    );
  }

  // Admin: melihat chat pada laporan tertentu.
  Future<List<ChatMessageModel>> getChatAdmin(int laporanId) async {
    final body = await _request('GET', '/admin/laporan/$laporanId/chat');

    return _parseMessages(body);
  }

  // Admin: membalas pesan berdasarkan ID chat.
  Future<void> balasPesanAdmin({
    required int chatId,
    required String balasan,
  }) async {
    await _request('PUT', '/admin/chat/$chatId', data: {'balasan': balasan});
  }
}
