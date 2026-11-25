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
import 'package:roadis/utils/widgets/batik_patern.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:roadis/modules/chat/screens/chat_screen.dart';

class DetailLaporanScreen extends StatefulWidget {
  final LaporanModel laporan;

  const DetailLaporanScreen({super.key, required this.laporan});

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  LaporanModel get laporan => widget.laporan;

  final MapController _miniMapController = MapController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolled = _scrollController.hasClients && _scrollController.offset > 24;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  bool get _hasValidCoords =>
      laporan.latitude.isFinite &&
      laporan.longitude.isFinite &&
      laporan.latitude != 0 &&
      laporan.longitude != 0;

  // Status index: 0 = Terkirim, 1 = Ditinjau/Diproses, 2 = Selesai
  int get _statusStepIndex {
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
    return 0; // Menunggu
  }

  void _showImageDialog(BuildContext context, String imageUrl, String tagTitle) {
    if (imageUrl.isEmpty) return;
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, p) => p == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.skyBlue,
                            strokeWidth: 2.5,
                          ),
                        ),
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
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                tagTitle,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
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

  void _recenterMap() {
    if (!_hasValidCoords) return;
    HapticFeedback.selectionClick();
    _miniMapController.move(LatLng(laporan.latitude, laporan.longitude), 16.5);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final statusColor = laporan.status.statusColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurvedTopHeader(topInset, statusColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFotoCard(context)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 80.ms)
                          .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                      const SizedBox(height: 18),

                      _buildStatusTimeline(statusColor)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 140.ms)
                          .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                      const SizedBox(height: 18),

                      _buildKewenanganCard()
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 200.ms)
                          .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                      const SizedBox(height: 18),

                      _buildSpecGrid()
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 260.ms)
                          .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                      const SizedBox(height: 18),

                      _buildDeskripsiCard()
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 320.ms)
                          .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                      const SizedBox(height: 18),

                      _buildTindakLanjutCard(context)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 380.ms)
                          .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                      const SizedBox(height: 18),

                      if (_hasValidCoords)
                        _buildMiniPetaCard(context)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 440.ms)
                            .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildPinnedNavbar(topInset),
        ],
      ),
      bottomNavigationBar: _buildBottomActionDock()
          .animate()
          .fadeIn(duration: 450.ms, delay: 150.ms)
          .slideY(begin: 0.15, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildPinnedNavbar(double topInset) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          top: topInset + 6,
          left: 16,
          right: 16,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: _isScrolled ? AppColors.primaryColor : Colors.transparent,
          boxShadow: _isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.30),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isScrolled ? 1.0 : 0.0,
                child: Text(
                  'Detail Laporan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
              child: Text(
                '#RD-${laporan.id}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedTopHeader(double topInset, Color statusColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryColor,
            Color(0xFF0096C7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: Stack(
          children: [
            Positioned.fill(
              child: BatikPattern(
                color: Colors.white,
                opacity: 0.10,
                scale: 2.2,
                fadeOut: true,
              ),
            ),
            Positioned(
              top: topInset - 6,
              right: -4,
              width: 175,
              height: 155,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/images/burung_batik.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, topInset + 58, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
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
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 800.ms),
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
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Colors.white.withOpacity(0.88),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        laporan.waktuLaporan,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    laporan.tipeKerusakan.isNotEmpty
                        ? laporan.tipeKerusakan
                        : laporan.judul,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (laporan.wilayahNama != null &&
                      laporan.wilayahNama!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.88),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            laporan.wilayahNama!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.95),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoCard(BuildContext context) {
    final hasImage = laporan.image.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
                  'Foto Bukti Kerusakan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
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
            onTap: () => _showImageDialog(context, laporan.image, 'Foto Bukti Kerusakan'),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: !hasImage
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 42,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada foto kerusakan',
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
                          laporan.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, p) => p == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                    strokeWidth: 2.5,
                                  ),
                                ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  Widget _buildStatusTimeline(Color statusColor) {
    final current = _statusStepIndex;
    final steps = [
      {'title': 'Terkirim', 'sub': 'Laporan masuk'},
      {'title': 'Ditinjau', 'sub': 'Verifikasi teknis'},
      {'title': 'Selesai', 'sub': 'Perbaikan tuntas'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
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
                Icons.alt_route_rounded,
                size: 17,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Alur Penanganan Laporan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= current
                              ? (i == current ? statusColor : AppColors.greenColor)
                              : const Color(0xFFE2E8F0),
                          boxShadow: i <= current
                              ? [
                                  BoxShadow(
                                    color: (i == current ? statusColor : AppColors.greenColor).withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            i < current
                                ? Icons.check_rounded
                                : (i == current ? Icons.radio_button_checked_rounded : Icons.circle_outlined),
                            size: 17,
                            color: i <= current ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        steps[i]['title']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: i <= current ? FontWeight.w800 : FontWeight.w600,
                          color: i <= current ? AppColors.darkTextColor : Colors.grey.shade400,
                        ),
                      ),
                      Text(
                        steps[i]['sub']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2.5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: i < current ? AppColors.greenColor : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKewenanganCard() {
    final kewenangan = laporan.kewenanganJalan?.trim().toLowerCase() ?? '';
    String instansi;
    String badgeWilayah;
    String deskripsiKewenangan;
    IconData instansiIcon;

    if (kewenangan.contains('nasional')) {
      instansi = 'Kementerian PUPR (BBPJN VI)';
      badgeWilayah = 'Jalan Nasional';
      deskripsiKewenangan =
          'Ruas ini berstatus Jalan Nasional. Penanganan berada di bawah kewenangan Balai Besar Pelaksanaan Jalan Nasional.';
      instansiIcon = Icons.account_balance_rounded;
    } else if (kewenangan.contains('provinsi')) {
      instansi = 'Dinas Bina Marga & Penataan Ruang Jabar';
      badgeWilayah = 'Jalan Provinsi';
      deskripsiKewenangan =
          'Ruas ini merupakan jalan provinsi di bawah wewenang Pemerintah Provinsi Jawa Barat.';
      instansiIcon = Icons.account_balance_rounded;
    } else if (kewenangan.contains('desa')) {
      instansi = 'Pemerintah Desa Setempat';
      badgeWilayah = 'Jalan Desa';
      deskripsiKewenangan =
          'Ruas jalan lingkungan / desa yang dikelola secara swadaya atau melalui anggaran desa.';
      instansiIcon = Icons.home_work_rounded;
    } else if (kewenangan.contains('kabupaten')) {
      instansi = 'Dinas PUPR Kabupaten Indramayu';
      badgeWilayah = 'Jalan Kabupaten';
      deskripsiKewenangan =
          'Ruas jalan kabupaten yang menjadi tanggung jawab resmi Dinas Pekerjaan Umum Kabupaten Indramayu.';
      instansiIcon = Icons.location_city_rounded;
    } else {
      instansi = 'Pemerintah Kabupaten Indramayu';
      badgeWilayah = 'Verifikasi Wilayah';
      deskripsiKewenangan =
          'Kewenangan ruas jalan ini sedang dikonfirmasi oleh sistem GIS ROADIS Indramayu.';
      instansiIcon = Icons.help_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(instansiIcon, color: AppColors.primaryColor, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kewenangan Penanganan Resmi',
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
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  badgeWilayah,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
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

  Widget _buildSpecGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildSpecItem(
            icon: Icons.alt_route_rounded,
            title: 'Jenis Ruas',
            value: laporan.jenisJalan ?? 'Jalan Umum',
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSpecItem(
            icon: Icons.person_pin_rounded,
            title: 'Pelapor',
            value: laporan.namaPelapor ?? 'Warga Indramayu',
            color: AppColors.primaryDarkColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeskripsiCard() {
    final hasDeskripsi = laporan.deskripsi.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
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
                Icons.format_quote_rounded,
                size: 20,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Catatan / Deskripsi Pelapor',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasDeskripsi ? laporan.deskripsi : 'Tidak ada catatan deskripsi tambahan dari pelapor.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.6,
              color: hasDeskripsi ? const Color(0xFF334155) : AppColors.greyColor,
              fontStyle: hasDeskripsi ? FontStyle.normal : FontStyle.italic,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (adaBalasan || adaFoto) ? AppColors.greenColor.withOpacity(0.35) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
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
                  (adaBalasan || adaFoto) ? Icons.verified_rounded : Icons.support_agent_rounded,
                  size: 20,
                  color: (adaBalasan || adaFoto) ? AppColors.greenColor : AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tindak Lanjut & Balasan Resmi Dinas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    Text(
                      (adaBalasan || adaFoto)
                          ? 'Terverifikasi oleh pengelola jalan'
                          : 'Dalam antrean verifikasi lapangan',
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
                  fontWeight: FontWeight.w600,
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
                'Laporan ini telah masuk ke sistem ROADIS dan menunggu giliran inspeksi lapangan dari petugas teknis.',
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
            Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  size: 16,
                  color: AppColors.greenColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Foto Bukti Pekerjaan Selesai:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImageDialog(context, foto, 'Foto Bukti Pekerjaan'),
              child: Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
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
                  'Titik Geospasial Kerusakan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkTextColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _copyCoordinates(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        const SizedBox(width: 5),
                        Text(
                          'Salin GPS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
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
            height: 220,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Live interactive draggable map!
                FlutterMap(
                  mapController: _miniMapController,
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 16.5,
                    minZoom: 10.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
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
                          width: 48,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.redColor,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.45),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
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

                // Floating Re-center / Reset Button & Gesture Hint
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pan_tool_alt_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Peta dapat digeser',
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

                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _recenterMap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.my_location_rounded,
                            color: AppColors.primaryColor,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Titik Awal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
