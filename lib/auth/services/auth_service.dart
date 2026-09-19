import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:roadis/core/api_config.dart';
import '../models/user_model.dart';

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

    return LoginResult(
      body['token'],
      UserModel.fromJson(body['user']),
    );
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