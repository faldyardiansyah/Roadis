import 'package:get/get.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/core/laporan/services/laporan_service.dart';

class HistoryController extends GetxController {
  final _service = LaporanService();

  final isLoading = true.obs;
  final errorMessage = RxnString();

  final semuaLaporan = <LaporanModel>[].obs;
  final selectedFilter = 'Semua'.obs;
  final searchQuery = ''.obs;

  static const filterOptions = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Selesai',
    'Ditolak',
  ];

  List<LaporanModel> get filteredLaporan {
    var result = semuaLaporan.toList();

    if (selectedFilter.value != 'Semua') {
      result = result.where((e) {
        return e.status.statusLabel.toLowerCase().trim() ==
            selectedFilter.value.toLowerCase().trim();
      }).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((e) {
        final nomorTiket = 'jk-${e.id}'.toLowerCase();

        final judul = e.judul.toLowerCase();
        final tipeKerusakan = e.tipeKerusakan.toLowerCase();
        final wilayah = (e.wilayahNama ?? '').toLowerCase();
        final deskripsi = (e.deskripsi ?? '').toLowerCase();
        final status = e.status.statusLabel.toLowerCase();
        final catatanAdmin = (e.catatanAdmin ?? '').toLowerCase();
        if (catatanAdmin.contains(query)) return true;

        return nomorTiket.contains(query) ||
            judul.contains(query) ||
            tipeKerusakan.contains(query) ||
            wilayah.contains(query) ||
            deskripsi.contains(query) ||
            status.contains(query) ||
            catatanAdmin.contains(query) ||
            catatanAdmin.contains(query);
      }).toList();
    }

    return result;
  }

  int countFor(String filter) {
    if (filter == 'Semua') {
      return semuaLaporan.length;
    }

    return semuaLaporan.where((e) {
      return e.status.statusLabel.toLowerCase().trim() ==
          filter.toLowerCase().trim();
    }).length;
  }

  @override
  void onInit() {
    super.onInit();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      semuaLaporan.value = await _service.getRiwayat();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }
}
