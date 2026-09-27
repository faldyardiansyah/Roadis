import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadis/auth/controllers/auth_controller.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/core/laporan/services/laporan_service.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final _service = LaporanService();
  final _profileService = ProfileService();
  final authC = Get.find<AuthController>();

  final isLoadingStats = true.obs;
  final errorStats = RxnString();
  final riwayat = <LaporanModel>[].obs;

  final isUploadingPhoto = false.obs;
  final photoError = RxnString();

  int get totalLaporan => riwayat.length;
  int get totalSelesai =>
      riwayat.where((l) => l.status.toLowerCase() == 'selesai').length;
  int get totalDiproses =>
      riwayat.where((l) => l.status.toLowerCase() == 'proses').length;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoadingStats.value = true;
    errorStats.value = null;
    try {
      riwayat.value = await _service.getRiwayat();
    } catch (e) {
      errorStats.value = e.toString();
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> pickAndUploadPhoto(ImageSource source) async {
    debugPrint('1. pickAndUploadPhoto dipanggil, source: $source');

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );

    debugPrint('2. Hasil pickImage: ${picked?.name ?? "NULL (user batal atau gagal)"}');

    if (picked == null) return;

    isUploadingPhoto.value = true;
    photoError.value = null;

    try {
      debugPrint('3. Membaca bytes gambar...');
      final Uint8List bytes = await picked.readAsBytes();
      debugPrint('4. Bytes terbaca, ukuran: ${bytes.length}');

      debugPrint('5. Mengirim ke server...');
      final url = await _profileService.uploadPhoto(bytes, picked.name);
      debugPrint('6. Upload sukses, URL: $url');

      await authC.updateLocalProfilePhoto(url);
      debugPrint('7. Sesi lokal diupdate');
    } catch (e, st) {
      debugPrint('ERROR pickAndUploadPhoto: $e');
      debugPrint('STACK: $st');
      photoError.value = e.toString();
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> logout() async {
    await authC.logout();
  }
}