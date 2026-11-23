import 'dart:async';
import 'package:get/get.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/auth/services/session_storage.dart';

class OnboardingController extends GetxController {
  final List<String> pesanList = [
    "Menghubungkan ke sistem ROADIS...",
    "Memverifikasi modul deteksi AI...",
    "Memuat data geospasial Indramayu...",
    "Menyiapkan pengalaman terbaik untuk Anda...",
  ];

  var pesanSaatIni = ''.obs;
  var _index = 0;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    pesanSaatIni.value = pesanList[0];
    _mulaiGantiPesan();
    _pindahHalaman();
  }

  void _mulaiGantiPesan() {
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      _index = (_index + 1) % pesanList.length;
      pesanSaatIni.value = pesanList[_index];
    });
  }

  void _pindahHalaman() {
    Future.delayed(const Duration(milliseconds: 3200), () {
      _timer?.cancel();

      final token = SessionStorage.getToken();

      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.offNamed(AppRoutes.splash1);
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
