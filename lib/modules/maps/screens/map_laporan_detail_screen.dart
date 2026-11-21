import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';

class MapLaporanDetailScreen extends StatelessWidget {
  final LaporanModel laporan;

  const MapLaporanDetailScreen({super.key, required this.laporan});

  bool get _koordinatValid =>
      laporan.latitude.isFinite &&
      laporan.longitude.isFinite &&
      laporan.latitude >= -90 &&
      laporan.latitude <= 90 &&
      laporan.longitude >= -180 &&
      laporan.longitude <= 180;

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF172033),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
  }

  Future<void> _openGoogleMaps(BuildContext context) async {
    if (!_koordinatValid) {
      _snack(context, 'Koordinat lokasi laporan tidak valid.');
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${laporan.latitude},${laporan.longitude}',
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _snack(context, 'Google Maps tidak dapat dibuka.');
      }
    } catch (_) {
      if (context.mounted) {
        _snack(context, 'Terjadi kesalahan saat membuka Google Maps.');
      }
    }
  }

  Future<void> _copyCoordinates(BuildContext context) async {
    if (!_koordinatValid) {
      _snack(context, 'Koordinat lokasi laporan tidak valid.');
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: '${laporan.latitude}, ${laporan.longitude}'),
    );
    HapticFeedback.lightImpact();

    if (context.mounted) _snack(context, 'Koordinat berhasil disalin.');
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _handle()),
                  const SizedBox(height: 16),
                  Text(
                    'Pilihan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _optionTile(
                    icon: Icons.map_rounded,
                    title: 'Buka lokasi di Google Maps',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openGoogleMaps(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _optionTile(
                    icon: Icons.copy_rounded,
                    title: 'Salin koordinat lokasi',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _copyCoordinates(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _iconBox(icon, AppColors.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF172033),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _a(Widget child, int delay) {
    return child
        .animate()
        .fadeIn(duration: 380.ms, delay: delay.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: 380.ms,
          delay: delay.ms,
          curve: Curves.easeOutCubic,
        );
  }

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 340,
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leadingWidth: 64,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _glassButton(
                    Icons.arrow_back_rounded,
                    () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _glassButton(
                      Icons.more_horiz_rounded,
                      () => _showOptions(context),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Hero(
                    tag: 'laporan-image-${laporan.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        laporan.image.trim().isNotEmpty
                            ? Image.network(
                                laporan.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x88000000),
                                Color(0x11000000),
                                Color(0xD0000000),
                              ],
                              stops: [0, 0.4, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: BatikPattern(
                              height: 200,
                              color: Colors.white,
                              opacity: 0.18,
                              scale: 2.4,
                              fadeOut: true,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 40,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _statusBadge(color),
                              const SizedBox(height: 12),
                              Text(
                                laporan.tipeKerusakan.trim().isNotEmpty
                                    ? laporan.tipeKerusakan
                                    : laporan.judul,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 25,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.tag_rounded,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'JK-${laporan.id}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      laporan.waktuLaporan,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.9),
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
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -26),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _handle()),
                          const SizedBox(height: 18),
                          _a(_buildStatusHero(), 0),
                          const SizedBox(height: 14),
                          _a(_buildQuickTiles(), 60),
                          const SizedBox(height: 14),
                          _a(_buildKewenanganCard(), 100),
                          const SizedBox(height: 14),
                          _a(_buildDescriptionCard(), 140),
                          if (_hasAdminContent()) ...[
                            const SizedBox(height: 14),
                            _a(_buildAdminCard(), 180),
                          ],
                          if (_koordinatValid) ...[
                            const SizedBox(height: 14),
                            _a(_buildMapCard(context), 220),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  bool _hasAdminContent() =>
      laporan.catatanAdmin.trim().isNotEmpty ||
      laporan.fotoBukti.trim().isNotEmpty;

  Widget _handle() {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFD9E0E9),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _statusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            laporan.status.statusLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHero() {
    final status = laporan.status.statusLabel.toLowerCase();
    final selesai = status.contains('selesai');
    final ditolak = status.contains('tolak');
    final diproses = status.contains('proses');

    final base = selesai
        ? AppColors.greenColor
        : ditolak
        ? AppColors.redColor
        : AppColors.primaryColor;

    final ikon = selesai
        ? Icons.verified_rounded
        : ditolak
        ? Icons.cancel_rounded
        : diproses
        ? Icons.engineering_rounded
        : Icons.hourglass_top_rounded;

    final judul = selesai
        ? 'Penanganan selesai'
        : ditolak
        ? 'Laporan ditolak'
        : diproses
        ? 'Sedang diproses'
        : 'Menunggu verifikasi';

    final deskripsi = selesai
        ? 'Admin telah menandai laporan ini selesai.'
        : ditolak
        ? (laporan.catatanAdmin.trim().isNotEmpty
              ? laporan.catatanAdmin.trim()
              : 'Laporan ini tidak dilanjutkan ke tahap penanganan.')
        : diproses
        ? 'Laporan sedang ditangani oleh admin.'
        : 'Laporan telah tercatat dan menunggu verifikasi admin.';

    final done = selesai ? 4 : (diproses ? 2 : 1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, Color.lerp(base, Colors.black, 0.32)!],
        ),
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(0.3),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: BatikPattern(
                color: Colors.white,
                opacity: 0.16,
                scale: 2.4,
                fadeOut: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(ikon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status penanganan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              judul,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              deskripsi,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                height: 1.55,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!ditolak) ...[
                    const SizedBox(height: 20),
                    _buildStepper(done),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(int done) {
    const labels = ['Terkirim', 'Verifikasi', 'Diproses', 'Selesai'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                _stepDot(isDone: i < done, isActive: i == done),
                const SizedBox(height: 7),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: i <= done ? FontWeight.w800 : FontWeight.w500,
                    color: i <= done
                        ? Colors.white
                        : Colors.white.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _stepDot({required bool isDone, required bool isActive}) {
    return SizedBox(
      height: 26,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 26 : 22,
          height: isActive ? 26 : 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? Colors.white : Colors.white.withOpacity(0.18),
            border: Border.all(
              color: isActive || isDone
                  ? Colors.white
                  : Colors.white.withOpacity(0.35),
              width: isActive ? 3 : 1.5,
            ),
          ),
          child: isDone
              ? Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.primaryColor,
                )
              : isActive
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildQuickTiles() {
    final wilayah = laporan.wilayahNama?.trim().isNotEmpty == true
        ? laporan.wilayahNama!.trim()
        : '-';
    final pelapor = laporan.namaPelapor?.trim().isNotEmpty == true
        ? laporan.namaPelapor!.trim()
        : 'Warga';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _miniTile(Icons.location_city_rounded, 'Wilayah', wilayah),
        ),
        const SizedBox(width: 12),
        Expanded(child: _miniTile(Icons.person_rounded, 'Pelapor', pelapor)),
      ],
    );
  }

  Widget _miniTile(IconData icon, String label, String value) {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(icon, AppColors.primaryColor),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172033),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKewenanganCard() {
    final kewenangan = laporan.kewenanganJalan?.trim() ?? '';
    final jenis = kewenangan.toLowerCase().replaceAll('_', ' ');

    final belumPasti =
        jenis.isEmpty ||
        jenis == 'belum pasti' ||
        jenis == 'belum diketahui' ||
        jenis == 'perlu verifikasi' ||
        jenis == 'belum terverifikasi';

    final nama = belumPasti
        ? 'Belum terverifikasi'
        : jenis
              .split(' ')
              .where((kata) => kata.isNotEmpty)
              .map((kata) => '${kata[0].toUpperCase()}${kata.substring(1)}')
              .join(' ');

    final accent = belumPasti
        ? const Color(0xFF946200)
        : AppColors.primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: belumPasti
            ? const Color(0xFFFFF8E8)
            : AppColors.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: belumPasti
              ? const Color(0xFFF0DFB6)
              : AppColors.primaryColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(Icons.account_balance_rounded, accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kewenangan jalan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  nama,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  belumPasti
                      ? 'Kewenangan ruas jalan ini perlu diperiksa sebelum laporan diteruskan ke pihak terkait.'
                      : 'Pastikan kewenangan ini sesuai dengan data ruas jalan resmi.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    height: 1.55,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.notes_rounded, 'Deskripsi'),
          const SizedBox(height: 12),
          Text(
            laporan.deskripsi.trim().isNotEmpty
                ? laporan.deskripsi
                : 'Tidak ada deskripsi yang diberikan untuk laporan ini.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.7,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard() {
    final catatan = laporan.catatanAdmin.trim();
    final foto = laporan.fotoBukti.trim();
    final selesai = laporan.status.statusLabel.toLowerCase().contains(
      'selesai',
    );

    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.support_agent_rounded, 'Tindak lanjut admin'),
          if (catatan.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                catatan,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  height: 1.65,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
          if (foto.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              selesai ? 'Foto hasil perbaikan' : 'Foto bukti penanganan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                foto,
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    height: 210,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 130,
                    alignment: Alignment.center,
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 32,
                      color: Color(0xFF94A3B8),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard(BuildContext context) {
    final point = LatLng(laporan.latitude, laporan.longitude);
    final color = laporan.status.statusColor;

    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.location_on_rounded, AppColors.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Titik lokasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${laporan.latitude.toStringAsFixed(5)}, ${laporan.longitude.toStringAsFixed(5)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _copyCoordinates(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Salin',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.roadis.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 56,
                          height: 56,
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _copyCoordinates(context),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.copy_rounded,
                size: 22,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () => _openGoogleMaps(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_rounded, size: 20),
                    const SizedBox(width: 9),
                    Text(
                      'Buka di Google Maps',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 17),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        _iconBox(icon, AppColors.primaryColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172033),
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 19, color: color),
    );
  }

  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            Color.lerp(AppColors.primaryColor, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add_road_rounded,
          size: 64,
          color: Colors.white.withOpacity(0.35),
        ),
      ),
    );
  }
}
