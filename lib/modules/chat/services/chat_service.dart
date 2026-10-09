
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:roadis/core/api_config.dart';
import 'package:roadis/auth/services/session_storage.dart';
import 'package:roadis/modules/chat/models/chat_message_model.dart';

class ChatService {
  String get _apiBase {
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');

    return base.endsWith('/api') ? base : '$base/api';
  }

  Future<Map<String, String>> _headers() async {
    final token = await SessionStorage.getToken();

    if (token == null || token.toString().isEmpty) {
      throw Exception('Token login tidak ditemukan. Silakan login kembali.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _decodeResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map
          ? (body['message'] ?? body['error'] ?? 'Permintaan gagal')
          : 'Permintaan gagal';

      throw Exception('$message (HTTP ${response.statusCode})');
    }

    return body;
  }

  Future<List<ChatMessageModel>> getChat(int laporanId) async {
    final response = await http.get(
      Uri.parse('$_apiBase/warga/laporan/$laporanId/chat'),
      headers: await _headers(),
    );

    final body = _decodeResponse(response);

    dynamic data = body;
    if (body is Map && body.containsKey('data')) {
      data = body['data'];
    }

    if (data is! List) {
      throw Exception('Format riwayat chat dari server tidak sesuai.');
    }

    return data
        .whereType<Map>()
        .map((item) => ChatMessageModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<void> sendMessage(int laporanId, String pesan) async {
    final response = await http.post(
      Uri.parse('$_apiBase/warga/laporan/$laporanId/chat'),
      headers: await _headers(),
      body: jsonEncode({'pesan': pesan}),
    );

    _decodeResponse(response);
  }
}