import 'package:get/get.dart';
import 'package:roadis/modules/home/models/laporan_model.dart';
import 'package:roadis/modules/home/services/laporan_service.dart';

class MapsController extends GetxController {
  final _service = LaporanService();

  final isLoading = true.obs;
  final errorMessage = RxnString();

  final semuaLaporan = <LaporanModel>[].obs;
  final selectedFilter = 'Semua'.obs;
  final selectedLaporan = Rxn<LaporanModel>();

  // menyimpan teks yang diketik di kotak pencarian
  final searchQuery = ''.obs;

  static const filterOptions = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

  // sekarang menyaring berdasarkan status DAN teks pencarian
  List<LaporanModel> get filteredLaporan {
    var result = semuaLaporan.toList();
    if (selectedFilter.value != 'Semua') {
      result = result
          .where((e) => e.status.statusLabel == selectedFilter.value)
          .toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((e) {
        return e.judul.toLowerCase().contains(query) ||
            e.tipeKerusakan.toLowerCase().contains(query) ||
            (e.wilayahNama ?? '').toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  int countFor(String filter) {
    if (filter == 'Semua') return semuaLaporan.length;
    return semuaLaporan.where((e) => e.status.statusLabel == filter).length;
  }

  @override
  void onInit() {
    super.onInit();
    fetchLaporan();
  }

  Future<void> fetchLaporan() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _service.getPeta();
      semuaLaporan.value =
          data.where((e) => e.status.toLowerCase() != 'ditolak').toList();
      if (semuaLaporan.isNotEmpty) {
        selectedLaporan.value = semuaLaporan.first;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void selectLaporan(LaporanModel laporan) {
    selectedLaporan.value = laporan;
  }

  void closeDetailCard() {
    selectedLaporan.value = null;
  }

  // dipanggil setiap kali user ngetik
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // dipanggil dari tombol tune, reset semuanya
  void resetFilters() {
    searchQuery.value = '';
    selectedFilter.value = 'Semua';
  }
}