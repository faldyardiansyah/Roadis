import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:roadis/modules/chat/screens/chat_screen.dart';

class DetailLaporanScreen extends StatelessWidget {
  final LaporanModel laporan;

  const DetailLaporanScreen({super.key, required this.laporan});

  bool get _hasValidCoords =>
      laporan.latitude.isFinite &&
      laporan.longitude.isFinite &&
      laporan.latitude != 0 &&
      laporan.longitude != 0;

  void _showImageDialog(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(ctx).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    HapticFeedback.lightImpact();
    if (!_hasValidCoords) {
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

  void _copyCoordinates(BuildContext context) {
    if (!_hasValidCoords) return;
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
            const Icon(Icons.check_circle_rounded, color: AppColors.skyBlue, size: 18),
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

  @override
  Widget build(BuildContext context) {
    final statusColor = laporan.status.statusColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.darkTextColor,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Detail Laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#RD-${laporan.id}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Status Card dengan Watermark Burung Khas Indramayu
            _buildHeroStatusCard(statusColor)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),

            const SizedBox(height: 18),

            // 2. Foto Kerusakan Jalan (Interactive Full-Screen Preview)
            _buildFotoSection(context)
                .animate()
                .fadeIn(duration: 450.ms, delay: 100.ms)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),

            const SizedBox(height: 18),

            // 3. Kartu Kewenangan & Penanggung Jawab Ruas Jalan
            _buildKewenanganCard()
                .animate()
                .fadeIn(duration: 450.ms, delay: 180.ms)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),

            const SizedBox(height: 18),

            // 4. Deskripsi Laporan Warga
            _buildDeskripsiCard()
                .animate()
                .fadeIn(duration: 450.ms, delay: 240.ms)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),

            const SizedBox(height: 18),

            // 5. Balasan Resmi & Bukti Tindak Lanjut Admin Dinas
            _buildTindakLanjutCard(context)
                .animate()
                .fadeIn(duration: 450.ms, delay: 300.ms)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),

            const SizedBox(height: 18),

            // 6. Mini Peta Geospasial
            if (_hasValidCoords)
              _buildMiniPetaCard(context)
                  .animate()
                  .fadeIn(duration: 450.ms, delay: 360.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // 7. Sticky Bottom Action Dock (Chat Admin & Navigasi)
      bottomNavigationBar: _buildBottomActionDock(),
    );
  }

  // -------------------------------------------------------------
  // WIDGETS
  // -------------------------------------------------------------

  Widget _buildHeroStatusCard(Color statusColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.deepNavy,
            AppColors.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Watermark Burung Khas Indramayu di Pojok Kanan Kartu
            Positioned(
              right: -25,
              top: -15,
              bottom: -15,
              width: 190,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.16,
                  child: Image.asset(
                    'assets/images/burung_batik.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Badge Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              laporan.status.statusLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Tipe Jalan Pill
                      if (laporan.jenisJalan != null && laporan.jenisJalan!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            'Jalan ${laporan.jenisJalan}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    laporan.tipeKerusakan.isNotEmpty
                        ? laporan.tipeKerusakan
                        : laporan.judul,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        laporan.waktuLaporan,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (laporan.wilayahNama != null &&
                          laporan.wilayahNama!.isNotEmpty) ...[
                        Text(
                          '  •  ',
                          style: TextStyle(color: Colors.white.withOpacity(0.6)),
                        ),
                        Flexible(
                          child: Text(
                            laporan.wilayahNama!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoSection(BuildContext context) {
    final url = laporan.image;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.photo_camera_rounded,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Foto Kerusakan Jalan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'Ketuk untuk perbesar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showImageDialog(context, url),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: url.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada foto',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primaryColor,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 44,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Perbesar',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildKewenanganCard() {
    final kewenangan = laporan.kewenanganJalan?.trim().toLowerCase() ?? '';
    String instansi;
    String deskripsiKewenangan;
    IconData instansiIcon;

    if (kewenangan.contains('nasional')) {
      instansi = 'Kementerian PUPR (BBPJN VI)';
      deskripsiKewenangan =
          'Ruas ini merupakan jalan nasional. Laporan diteruskan ke Balai Besar Pelaksanaan Jalan Nasional.';
      instansiIcon = Icons.account_balance_rounded;
    } else if (kewenangan.contains('provinsi')) {
      instansi = 'Dinas Bina Marga & Penataan Ruang Prov. Jabar';
      deskripsiKewenangan =
          'Ruas ini merupakan kewenangan Pemerintah Provinsi Jawa Barat.';
      instansiIcon = Icons.account_balance_rounded;
    } else if (kewenangan.contains('desa')) {
      instansi = 'Pemerintah Desa Setempat';
      deskripsiKewenangan =
          'Ruas jalan lingkungan / desa yang dikelola oleh pemerintah desa.';
      instansiIcon = Icons.home_work_rounded;
    } else if (kewenangan.contains('kabupaten')) {
      instansi = 'Dinas PUPR Kabupaten Indramayu';
      deskripsiKewenangan =
          'Ruas jalan kabupaten di bawah kewenangan teknis Dinas Pekerjaan Umum Kabupaten Indramayu.';
      instansiIcon = Icons.location_city_rounded;
    } else {
      instansi = 'Pemerintah Kabupaten Indramayu';
      deskripsiKewenangan =
          'Kewenangan ruas jalan ini sedang diverifikasi oleh admin teknis ROADIS.';
      instansiIcon = Icons.help_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  instansiIcon,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kewenangan Penanganan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyColor,
                    ),
                  ),
                  Text(
                    instansi,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              deskripsiKewenangan,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                height: 1.5,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeskripsiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notes_rounded,
                size: 18,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Deskripsi Laporan Warga',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            laporan.deskripsi.isEmpty
                ? 'Tidak ada catatan deskripsi tambahan dari pelapor.'
                : laporan.deskripsi,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.6,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTindakLanjutCard(BuildContext context) {
    final catatan = laporan.catatanAdmin.trim();
    final foto = laporan.fotoBukti.trim();
    final adaBalasan = catatan.isNotEmpty;
    final adaFoto = foto.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: (adaBalasan || adaFoto)
              ? AppColors.greenColor.withOpacity(0.35)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (adaBalasan || adaFoto)
                      ? AppColors.greenColor.withOpacity(0.12)
                      : AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  (adaBalasan || adaFoto)
                      ? Icons.verified_rounded
                      : Icons.support_agent_rounded,
                  size: 20,
                  color: (adaBalasan || adaFoto)
                      ? AppColors.greenColor
                      : AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tindak Lanjut & Balasan Dinas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    Text(
                      (adaBalasan || adaFoto)
                          ? 'Respon resmi dari pengelola jalan'
                          : 'Belum ada balasan dari petugas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (adaBalasan) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Text(
                catatan,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  height: 1.6,
                  color: const Color(0xFF166534),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Laporan Anda telah tercatat di sistem ROADIS dan sedang menunggu antrean inspeksi lapangan oleh petugas.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  height: 1.6,
                  color: AppColors.greyColor,
                ),
              ),
            ),
          ],
          if (adaFoto) ...[
            const SizedBox(height: 14),
            Text(
              'Foto Bukti Pekerjaan Selesai:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextColor,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImageDialog(context, foto),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  foto,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_rounded, size: 36),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniPetaCard(BuildContext context) {
    final lat = laporan.latitude;
    final lng = laporan.longitude;
    final point = LatLng(lat, lng);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppColors.redColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Titik Koordinat Lokasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _copyCoordinates(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Salin GPS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 180,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 16.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.jalanku.indramayu',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 46,
                      height: 46,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.redColor,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionDock() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Tombol Navigasi Google Maps
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _openGoogleMaps,
                  icon: const Icon(
                    Icons.navigation_rounded,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                  label: Text(
                    'Rute Peta',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primaryColor.withOpacity(0.35),
                    ),
                    backgroundColor: AppColors.primaryColor.withOpacity(0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Tombol Chat Admin Dinas
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
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
                  },
                  icon: const Icon(
                    Icons.chat_bubble_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Chat Petugas Admin',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
