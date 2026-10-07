import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class DetailLaporanScreen extends StatelessWidget {
  final LaporanModel laporan;
  const DetailLaporanScreen({super.key, required this.laporan});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () => Get.back(),
            style: IconButton.styleFrom(backgroundColor: AppColors.whiteColor),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.darkTextColor,
            ),
          ),
        ),
        title: Text(
          'Detail Laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFoto(),
              const SizedBox(height: 18),
              _buildHeader().animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.25, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 18),
              _buildInfoCard().animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.25, duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 18),
              _sectionTitle('Deskripsi').animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.25, duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 8),
              _buildDescription().animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.25, duration: 400.ms, delay: 250.ms),
              const SizedBox(height: 18),
              _buildPeta().animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.25, duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 18),
              _buildActionButtons().animate().fadeIn(duration: 400.ms, delay: 350.ms).slideY(begin: 0.25, duration: 400.ms, delay: 350.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoto() {
    final url = laporan.image;
    return Container(
      width: double.infinity,
      height: 235,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url == null || url.isEmpty)
            const Icon(
              Icons.image_not_supported_outlined,
              size: 44,
              color: AppColors.lightGreyColor,
            )
          else
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child;
                }
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryColor,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image_outlined,
                  size: 44,
                  color: AppColors.lightGreyColor,
                );
              },
            ),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Foto Laporan',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                '#JK-${laporan.id}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: laporan.status.statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: laporan.status.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    laporan.status.statusLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: laporan.status.statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          laporan.judul,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: AppColors.darkTextColor,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: AppColors.greyColor,
            ),
            const SizedBox(width: 5),
            Text(
              laporan.waktuLaporan,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(
            Icons.warning_amber_rounded,
            'Jenis Kerusakan',
            laporan.tipeKerusakan,
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.location_city_outlined,
            'Wilayah',
            laporan.wilayahNama ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Text(
        laporan.deskripsi ?? '-',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          height: 1.6,
          color: AppColors.darkTextColor,
        ),
      ),
    );
  }

  Widget _buildPeta() {
    final lat = laporan.latitude;
    final lng = laporan.longitude;
    if (lat == null || lng == null || !lat.isFinite || !lng.isFinite) {
      return const SizedBox();
    }
    final point = LatLng(lat, lng);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('Lokasi')),
            Text(
              '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 230,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 17,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.roadis',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 50,
                        height: 50,
                        alignment: Alignment.topCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.redColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.redColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: AppColors.redColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Lokasi Kerusakan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openGoogleMaps() async {
    final double? lat = laporan.latitude;
    final double? lng = laporan.longitude;
    if (lat == null || lng == null) {
      showAwesomeSnackbar(
        title: 'Lokasi Tidak Tersedia',
        message: 'Koordinat lokasi kerusakan tidak tersedia.',
        contentType: ContentType.warning,
      );
      return;
    }
    final googleMapsAppUri = Uri.parse('google.navigation:q=$lat,$lng');
    final googleMapsWebUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    try {
      final openedApp = await launchUrl(
        googleMapsAppUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedApp) {
        return;
      }
    } catch (_) {}
    try {
      final openedWeb = await launchUrl(
        googleMapsWebUri,
        mode: LaunchMode.externalApplication,
      );
      if (!openedWeb) {
        Get.snackbar(
          'Gagal Membuka Maps',
          'Google Maps tidak dapat dibuka di perangkat ini.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Gagal Membuka Maps',
        'Terjadi kesalahan saat membuka Google Maps.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openGoogleMaps,
            icon: const Icon(Icons.map_outlined, size: 19),
            label: Text(
              'Buka Google Maps',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: BorderSide(color: AppColors.primaryColor.withOpacity(0.35)),
              backgroundColor: AppColors.primaryColor.withOpacity(0.05),
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.whiteColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 21),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.darkTextColor,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.borderColor.withOpacity(0.7)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.greyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
