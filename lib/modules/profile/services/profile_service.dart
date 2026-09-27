import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:roadis/core/api_config.dart';
import 'package:roadis/auth/services/session_storage.dart';

class ProfileException implements Exception {
  final String message;

  ProfileException(this.message);
  @override
  String toString() => message;
}

class ProfileService {
  Future<String> uploadPhoto(Uint8List bytes, String filename) async {
    final token = SessionStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/profile/photo');

    final request = http.MultipartRequest('PUT', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      http.MultipartFile.fromBytes('foto', bytes, filename: filename),
    );

    try {
      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final res = await http.Response.fromStream(streamed);
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final data = body['data'] as Map<String, dynamic>;
        return data['profil_photo']?.toString() ?? '';
      }
      throw ProfileException(body['error']?.toString() ?? 'Gagal upload foto');
    } on TimeoutException {
      throw ProfileException('Koneksi timeout, coba lagi');
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Gagal upload foto');
    }
  }
}
