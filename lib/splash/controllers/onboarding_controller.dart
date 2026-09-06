import 'dart:async';
import 'package:get/get.dart';
import 'package:roadis/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final List<String> pesanList = [
    "Menyiapkan aplikasi ...",
    "Mempersiapkan untuk Anda ...",
    "Memuat data wilayah ...",
    "Hampir selesai ...",
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
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _index = (_index + 1) % pesanList.length;
      pesanSaatIni.value = pesanList[_index];
    });
  }

  void _pindahHalaman() {
    Future.delayed(const Duration(seconds: 4), () {
      _timer?.cancel();
      Get.offNamed(AppRoutes.splash1);
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
