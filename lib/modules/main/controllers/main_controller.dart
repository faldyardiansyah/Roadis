import 'package:get/get.dart';

class MainController extends GetxController {
  // Variabel reaktif untuk melacak indeks tab yang sedang aktif
  var currentIndex = 0.obs;

  // Fungsi untuk mengubah halaman/tab
  void changeTab(int index) {
    currentIndex.value = index;
  }
}