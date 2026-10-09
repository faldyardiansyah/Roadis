import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/utils/app_colors.dart';

class MapLaporanDetailScreen extends StatelessWidget {
  final LaporanModel laporan;

  const MapLaporanDetailScreen({super.key, required this.laporan});

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${laporan.latitude},${laporan.longitude}',
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened) {
        _showError();
      }
    } catch (_) {
      _showError();
    }
  }

  void _showError() {
    // Tidak ada SnackBar karena screen ini StatelessWidget.
  }

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 310,
                backgroundColor: Colors.white,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _glassCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _glassCircleButton(
                      icon: Icons.more_horiz_rounded,
                      onTap: () {},
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
                        laporan.image.isNotEmpty
                            ? Image.network(
                                laporan.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.42),
                                Colors.transparent,
                                Colors.black.withOpacity(0.68),
                              ],
                              stops: const [0.0, 0.42, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 22,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _statusBadge(color),
                                    const SizedBox(height: 10),
                                    Text(
                                      laporan.tipeKerusakan.isNotEmpty
                                          ? laporan.tipeKerusakan
                                          : laporan.judul,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 24,
                                        height: 1.15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.photo_camera_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
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
                  offset: const Offset(0, -18),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F8FB),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 26, 16, 125),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHandle(),

                          const SizedBox(height: 18),

                          Text(
                                'Detail Laporan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 450.ms, curve: Curves.easeOut)
                              .slideX(
                                begin: -0.04,
                                end: 0,
                                duration: 450.ms,
                                curve: Curves.easeOutCubic,
                              ),

                          const SizedBox(height: 5),

                          Text(
                            'Informasi lengkap mengenai laporan kerusakan jalan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fadeIn(duration: 450.ms, delay: 50.ms),

                          const SizedBox(height: 18),

                          _buildInfoCard()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 100.ms)
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration: 500.ms,
                                delay: 100.ms,
                                curve: Curves.easeOutCubic,
                              ),

                          const SizedBox(height: 14),

                          _buildDescriptionCard()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 170.ms)
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration: 500.ms,
                                delay: 170.ms,
                                curve: Curves.easeOutCubic,
                              ),

                          const SizedBox(height: 14),
                          _buildProgressCard().
                              animate()
                              .fadeIn(duration: 500.ms, delay: 210.ms)
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration: 500.ms,
                                delay: 210.ms,
                                curve: Curves.easeOutCubic,
                              ),

                          const SizedBox(height: 14),

                          _buildMapCard()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 240.ms)
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration: 500.ms,
                                delay: 240.ms,
                                curve: Curves.easeOutCubic,
                              ),
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
            child: _buildBottomBar(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(
                  begin: 0.25,
                  end: 0,
                  duration: 550.ms,
                  delay: 300.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _statusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.55), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            laporan.status.statusLabel.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _card(
      child: Column(
        children: [
          _infoRow(
            Icons.access_time_rounded,
            'Waktu Laporan',
            laporan.waktuLaporan,
            const Color(0xFF6C5CE7),
          ),
          _infoDivider(),
          _infoRow(
            Icons.location_on_rounded,
            'Wilayah',
            laporan.wilayahNama ?? '-',
            const Color(0xFFE91E63),
          ),
          _infoDivider(),
          _infoRow(
            Icons.person_outline_rounded,
            'Pelapor',
            laporan.namaPelapor ?? 'Warga',
            const Color(0xFF0284C7),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.notes_rounded, 'Deskripsi'),
          const SizedBox(height: 11),
          Text(
            laporan.deskripsi.isNotEmpty
                ? laporan.deskripsi
                : 'Tidak ada deskripsi yang diberikan untuk laporan ini.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.65,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final status = laporan.status.statusLabel.toLowerCase();

    final bool selesai = status.contains('selesai');
    final bool diproses =
        status.contains('proses') || status.contains('diproses');
    final bool ditolak = status.contains('tolak');

    final Color warna = selesai
        ? AppColors.greenColor
        : ditolak
        ? AppColors.redColor
        : diproses
        ? AppColors.primaryColor
        : AppColors.yellowColor;

    final Color warnaLatar = selesai
        ? AppColors.greenColorLight
        : ditolak
        ? AppColors.redColorLight
        : diproses
        ? AppColors.primaryColorLight
        : AppColors.yellowColorLight;

    final IconData ikon = selesai
        ? Icons.check_circle_rounded
        : ditolak
        ? Icons.cancel_rounded
        : diproses
        ? Icons.engineering_rounded
        : Icons.hourglass_top_rounded;

    final String judul = selesai
        ? 'Penanganan Selesai'
        : ditolak
        ? 'Laporan Ditolak'
        : diproses
        ? 'Sedang Diproses'
        : 'Menunggu Verifikasi';

    final String deskripsi = selesai
        ? 'Admin telah menandai laporan ini selesai.'
        : ditolak
        ? (laporan.catatanAdmin.isNotEmpty
              ? laporan.catatanAdmin
              : 'Laporan ini tidak dilanjutkan ke tahap penanganan.')
        : diproses
        ? 'Laporan sedang ditangani oleh admin.'
        : 'Laporan telah tercatat dan menunggu verifikasi admin.';

    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            Icons.track_changes_rounded,
            'Status & Progres Penanganan',
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: warnaLatar,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ikon, color: warna, size: 27),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: warna,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deskripsi,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.6,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (laporan.catatanAdmin.isNotEmpty && !ditolak) ...[
            const SizedBox(height: 16),
            Text(
              'Catatan Admin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTextColor,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              laporan.catatanAdmin,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.6,
                color: AppColors.greyColor,
              ),
            ),
          ],

          if (laporan.fotoBukti.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              selesai ? 'Foto Hasil Perbaikan' : 'Foto Bukti Penanganan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTextColor,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                laporan.fotoBukti,
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return Container(
                    height: 210,
                    color: AppColors.backgroundColor,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                          : null,
                      color: AppColors.primaryColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: AppColors.backgroundColor,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 34,
                          color: AppColors.greyColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Foto bukti gagal dimuat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_camera_back_outlined,
                    color: AppColors.greyColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selesai
                          ? 'Foto hasil perbaikan belum tersedia.'
                          : diproses
                          ? 'Foto progres belum diunggah admin.'
                          : ditolak
                          ? 'Tidak ada foto penanganan.'
                          : 'Foto progres akan muncul setelah admin mengunggahnya.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        height: 1.5,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    final point = LatLng(laporan.latitude, laporan.longitude);

    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.location_on_rounded, const Color(0xFF0284C7)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Titik Lokasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${laporan.latitude.toStringAsFixed(5)}, '
                      '${laporan.longitude.toStringAsFixed(5)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: SizedBox(
              height: 185,
              width: double.infinity,
              child: Stack(
                children: [
                  IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: 15.5,
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
                              width: 70,
                              height: 70,
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 62,
                                    height: 62,
                                    decoration: BoxDecoration(
                                      color: laporan.status.statusColor
                                          .withOpacity(0.16),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.16),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: laporan.status.statusColor,
                                      size: 29,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(10),
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
                          Icon(
                            Icons.my_location_rounded,
                            size: 12,
                            color: laporan.status.statusColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Lokasi Kerusakan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF334155),
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
            blurRadius: 25,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _openGoogleMaps,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.map_rounded, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                'Buka di Google Maps',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 17),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        _iconBox(icon, const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          _iconBox(icon, accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoDivider() {
    return Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9));
  }

  Widget _glassCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.38),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.28)),
        ),
        child: IconButton(
          onPressed: onTap,
          splashRadius: 22,
          icon: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 46,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
