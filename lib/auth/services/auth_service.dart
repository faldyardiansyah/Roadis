import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:roadis/core/api_config.dart';

import '../models/user_model.dart';
import '../services/session_storage.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class LoginResult {
  final String token;
  final UserModel user;
  LoginResult(this.token, this.user);
}

class AuthService {
  static const _headers = {'Content-Type': 'application/json'};

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _post('/register', {
        'name': name,
        'email': email,
        'password': password,
      }, expected: 201);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Terjadi kesalahan tak terduga.';
    }
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final body = await _post('/login', {
      'email': email,
      'password': password,
    }, expected: 200);

    return LoginResult(body['token'], UserModel.fromJson(body['user']));
  }

  // Update nama profil ke backend
  Future<void> updateProfileName({required String name}) async {
    final token = SessionStorage.getToken();

    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan');
    }

    try {
      final res = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'name': name}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        return;
      }

      throw AuthException(
        body['message']?.toString() ??
            body['error']?.toString() ??
            'Gagal memperbarui nama',
      );
    } on SocketException {
      throw AuthException('Tidak bisa terhubung ke server');
    } on http.ClientException {
      throw AuthException('Tidak bisa terhubung ke server');
    } on TimeoutException {
      throw AuthException('Koneksi timeout, coba lagi');
    } on FormatException {
      throw AuthException('Respons server tidak valid');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = SessionStorage.getToken();

    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan');
    }

    try {
      final res = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/profile/password'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        return;
      }

      throw AuthException(
        body['message']?.toString() ??
            body['error']?.toString() ??
            'Gagal memperbarui kata sandi',
      );
    } on SocketException {
      throw AuthException('Tidak bisa terhubung ke server');
    } on http.ClientException {
      throw AuthException('Tidak bisa terhubung ke server');
    } on TimeoutException {
      throw AuthException('Koneksi timeout, coba lagi');
    } on FormatException {
      throw AuthException('Respons server tidak valid');
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload, {
    required int expected,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == expected) return body;
      throw AuthException(body['error']?.toString() ?? 'Terjadi kesalahan');
    } on SocketException {
      throw AuthException('Tidak bisa terhubung ke server');
    } on http.ClientException {
      throw AuthException('Tidak bisa terhubung ke server');
    } on TimeoutException {
      throw AuthException('Koneksi timeout, coba lagi');
    } on FormatException {
      throw AuthException('Respons server tidak valid');
    }
  }
}
