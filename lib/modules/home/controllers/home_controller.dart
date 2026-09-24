import 'dart:convert';
import 'package:get/get.dart';

import '../models/laporan_model.dart';
import '../services/laporan_service.dart';


class HomeController extends GetxController{
  final _service = LaporanService();

  final isLoadingStats = true.obs;
  final isLoadingMap = true.obs;
  final errorStats = RxnString();
  final errorMap = RxnString();

  final riwayat = <LaporanModel>[].obs;
  final petaLaporan = <LaporanModel>[].obs;

  int get totalLaporan => riwayat.length;
   int get totalDiproses =>
      riwayat.where((l) => l.status.toLowerCase() == 'diproses').length;
  int get totalSelesai =>
      riwayat.where((l) => l.status.toLowerCase() == 'selesai').length;
  
  List<LaporanModel> get recentReports => riwayat.take(2).toList();

  @override
  void onInit() {
    super.onInit();
    fetchRiwayat();
    fetchPeta();
  }

  Future<void> fetchRiwayat() async {
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

  Future<void> fetchPeta() async {
    isLoadingMap.value = true;
    errorMap.value = null;
    try {
      petaLaporan.value = await _service.getPeta();
    } catch (e) {
      errorMap.value = e.toString();
    } finally {
      isLoadingMap.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchRiwayat(), fetchPeta()]);
  }
}