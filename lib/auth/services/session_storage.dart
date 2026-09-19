import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class SessionStorage {
  static final _box = GetStorage();
  static const _tokenKey = 'token';
  static const _userKey = 'user';

  static Future<void> save(String token, UserModel user) async {
    await _box.write(_tokenKey, token);
    await _box.write(_userKey, jsonEncode(user.toJson()));
  }

  static String? getToken() => _box.read<String>(_tokenKey);
   static UserModel? getUser() {
    final raw = _box.read<String>(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }
   static Future<void> clear() async {
    await _box.remove(_tokenKey);
    await _box.remove(_userKey);
  }
}