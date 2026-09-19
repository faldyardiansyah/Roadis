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
