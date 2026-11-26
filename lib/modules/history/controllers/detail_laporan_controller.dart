import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/modules/chat/screens/chat_screen.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailLaporanController extends GetxController {
  final LaporanModel laporan;

  DetailLaporanController(this.laporan);

  final MapController miniMapController = MapController();
  final ScrollController scrollController = ScrollController();
  final isScrolled = false.obs;

  bool get hasValidCoords =>
      laporan.latitude.isFinite &&
      laporan.longitude.isFinite &&
      laporan.latitude != 0 &&
      laporan.longitude != 0;

  int get statusStepIndex {
    final s = laporan.status.toLowerCase().trim();
    if (s.contains('selesai') || s.contains('done') || s.contains('resolved')) {
      return 2;
    }
    if (s.contains('proses') ||
        s.contains('tinjau') ||
        s.contains('progress') ||
        s.contains('verifikasi')) {
      return 1;
    }
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    miniMapController.dispose();
    super.onClose();
  }

  void _onScroll() {
    final scrolled = scrollController.hasClients && scrollController.offset > 24;
    if (scrolled != isScrolled.value) {
      isScrolled.value = scrolled;
    }
  }

  Future<void> openGoogleMaps() async {
    HapticFeedback.lightImpact();
    if (!hasValidCoords) {
      showAwesomeSnackbar(
        title: 'Lokasi Tidak Valid',
        message: 'Koordinat lokasi kerusakan tidak tersedia.',
        contentType: ContentType.warning,
      );
      return;
    }

    final lat = laporan.latitude;
    final lng = laporan.longitude;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        showAwesomeSnackbar(
          title: 'Gagal Membuka Peta',
          message: 'Google Maps tidak dapat dibuka pada perangkat ini.',
          contentType: ContentType.failure,
        );
      }
    } catch (_) {
      showAwesomeSnackbar(
        title: 'Terjadi Kesalahan',
        message: 'Gagal mengarahkan rute navigasi.',
        contentType: ContentType.failure,
      );
    }
  }

  void copyCoordinates(BuildContext context) {
    if (!hasValidCoords) return;
    Clipboard.setData(
      ClipboardData(text: '${laporan.latitude}, ${laporan.longitude}'),
    );
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkTextColor,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.skyBlue,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Koordinat GPS berhasil disalin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void recenterMap() {
    if (!hasValidCoords) return;
    HapticFeedback.selectionClick();
    miniMapController.move(LatLng(laporan.latitude, laporan.longitude), 16.5);
  }

  void openChatScreen() {
    HapticFeedback.lightImpact();
    Get.to(
      () => ChatScreen(
        laporanId: laporan.id,
        jenisJalan: laporan.jenisJalan,
        kewenanganJalan: laporan.kewenanganJalan,
        wilayahNama: laporan.wilayahNama,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
