import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/widgets/loading_overlay.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/session_storage.dart';

class AuthController extends GetxController {
  final _service = AuthService();

  // Text controller login
  final loginEmailC = TextEditingController();
  final loginPassC = TextEditingController();

  // Text controller register
  final nameC = TextEditingController();
  final registerEmailC = TextEditingController();
  final registerPassC = TextEditingController();

  final Rxn<UserModel> user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    user.value = SessionStorage.getUser(); // pulihkan sesi
  }

  bool get isLoggedIn => SessionStorage.getToken() != null;

  void _error(String title, String message) {
    showAwesomeSnackbar(
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  Future<void> login(bool rememberMe) async {
    final email = loginEmailC.text.trim();
    final password = loginPassC.text;

    // Validasi email
    if (email.isEmpty) {
      _error('Gagal', 'Email wajib diisi.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _error('Gagal', 'Format email tidak valid.');
      return;
    }

    // Validasi password
    if (password.isEmpty) {
      _error('Gagal', 'Kata sandi wajib diisi.');
      return;
    }

    if (password.length < 6) {
      _error('Gagal', 'Kata sandi minimal 6 karakter.');
      return;
    }

    // Wajib centang "Ingat saya"
    if (!rememberMe) {
      showAwesomeSnackbar(
        title: 'Perhatian',
        message: 'Silakan centang "Ingat saya" terlebih dahulu.',
        contentType: ContentType.warning,
      );
      return;
    }

    // Loading hanya muncul kalau semua valid
    showLoadingOverlay();

    LoginResult result;

    try {
      result = await _service.login(email: email, password: password);
    } on AuthException catch (e) {
      Get.back();

      _error('Login Gagal', e.message);

      return;
    }

    await SessionStorage.save(result.token, result.user);

    user.value = result.user;
    loginEmailC.clear();
    loginPassC.clear();
    await Future.delayed(const Duration(milliseconds: 1000));
    Get.back();

    Get.offAllNamed(AppRoutes.main);

    showAwesomeSnackbar(
      title: 'Selamat Datang',
      message: 'Selamat datang kembali, ${result.user.nama}.',
      contentType: ContentType.success,
    );
  }

  Future<void> register(bool agreeTerms) async {
    final name = nameC.text.trim();
    final email = registerEmailC.text.trim();
    final password = registerPassC.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _error('Gagal', 'Semua field wajib diisi.');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      _error('Gagal', 'Format email tidak valid.');
      return;
    }
    if (password.length < 6) {
      _error('Gagal', 'Kata sandi minimal 6 karakter.');
      return;
    }

    if (!agreeTerms) {
      showAwesomeSnackbar(
        title: 'Perhatian',
        message: 'Setujui Syarat & Ketentuan terlebih dahulu.',
        contentType: ContentType.warning,
      );
      return;
    }

    showLoadingOverlay();

    final error = await _service.register(
      name: name,
      email: email,
      password: password,
    );

    if (error != null) {
      Get.back();
      _error('Registrasi Gagal', error);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    nameC.clear();
    registerEmailC.clear();
    registerPassC.clear();

    Get.back();
    Get.offAllNamed(AppRoutes.login);
    showAwesomeSnackbar(
      title: 'Berhasil',
      message: 'Akun berhasil dibuat, silakan masuk.',
      contentType: ContentType.success,
    );
  }

  Future<void> logout() async {
    await SessionStorage.clear();
    user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  // ini buat update profil
  Future<void> updateLocalProfilePhoto(String url) async {
    final current = user.value;
    if (current == null) return;

    final updated = current.copyWith(profilPhoto: url);
    user.value = updated;

    final token = SessionStorage.getToken();
    if (token != null) {
      await SessionStorage.save(token, updated);
    }
  }

  // Update nama di data lokal
  Future<void> updateLocalName(String newName) async {
    final current = user.value;
    if (current == null) return;

    final updated = current.copyWith(nama: newName);
    user.value = updated;

    final token = SessionStorage.getToken();
    if (token != null) {
      await SessionStorage.save(token, updated);
    }
  }

  Future<String?> updateName(String newName) async {
    final name = newName.trim();

    if (name.isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }

    try {
      await _service.updateProfileName(name: name);
      await updateLocalName(name);

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Terjadi kesalahan saat memperbarui nama.';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Terjadi kesalahan saat memperbarui kata sandi.';
    }
  }

  Future<String?> getProfileWilayah() async {
    try {
      final profile = await _service.getProfile();

      final wilayahData = profile['wilayah'];

      if (wilayahData == null) {
        return null;
      }

      return wilayahData['nama']?.toString();
    } on AuthException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSecurityInfo() async {
    try {
      final profile = await _service.getProfile();

      return {
        'last_login_at': profile['last_login_at'],
        'password_changed_at': profile['password_changed_at'],
      };
    } on AuthException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    loginEmailC.dispose();
    loginPassC.dispose();
    nameC.dispose();
    registerEmailC.dispose();
    registerPassC.dispose();
    super.onClose();
  }
}
