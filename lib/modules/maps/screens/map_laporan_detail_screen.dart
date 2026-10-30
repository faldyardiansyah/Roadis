import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:flutter/services.dart';
class MapLaporanDetailScreen extends StatelessWidget {
  final LaporanModel laporan;

  const MapLaporanDetailScreen({super.key, required this.laporan});

  Future<void> _openGoogleMaps(BuildContext context) async {
    final lat = laporan.latitude;
    final lng = laporan.longitude;

    if (!lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koordinat lokasi laporan tidak valid.'),
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Maps tidak dapat dibuka.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat membuka Google Maps.'),
          ),
        );
      }
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilihan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.map_outlined),
                  title: Text(
                    'Buka lokasi di Google Maps',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openGoogleMaps(context);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.copy_rounded),
                  title: Text(
                    'Salin koordinat lokasi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _copyCoordinates(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyCoordinates(BuildContext context) async {
    final lat = laporan.latitude;
    final lng = laporan.longitude;

    if (!lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koordinat lokasi laporan tidak valid.'),
        ),
      );
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: '$lat, $lng'),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koordinat berhasil disalin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;
    final koordinatValid = laporan.latitude.isFinite &&
        laporan.longitude.isFinite &&
        laporan.latitude >= -90 &&
        laporan.latitude <= 90 &&
        laporan.longitude >= -180 &&
        laporan.longitude <= 180;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
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
                      onTap: () => _showOptions(context),
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
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x55000000),
                                Colors.transparent,
                                Color(0xC9000000),
                              ],
                              stops: [0, 0.42, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 25,
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
                                  fontSize: 23,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Laporan #JK-${laporan.id}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.85),
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
                  offset: const Offset(0, -14),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHandle(),
                          const SizedBox(height: 20),
                          Text(
                            'Detail laporan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172033),
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                          const SizedBox(height: 5),
                          Text(
                            'Informasi dan perkembangan laporan kerusakan jalan.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              height: 1.5,
                              color: const Color(0xFF64748B),
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                          const SizedBox(height: 20),
                          _buildInfoCard()
                              .animate()
                              .fadeIn(duration: 350.ms, delay: 50.ms)
                              .slideY(begin: 0.035, end: 0),
                          const SizedBox(height: 14),
                          _buildDescriptionCard()
                              .animate()
                              .fadeIn(duration: 350.ms, delay: 100.ms),
                          const SizedBox(height: 14),
                          _buildProgressCard()
                              .animate()
                              .fadeIn(duration: 350.ms, delay: 140.ms),
                          if (koordinatValid) ...[
                            const SizedBox(height: 14),
                            _buildMapCard()
                                .animate()
                                .fadeIn(duration: 350.ms, delay: 180.ms),
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

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 34,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD9E0E9),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _statusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
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
            ),
          ),
          const SizedBox(width: 7),
          Text(
            laporan.status.statusLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final kewenangan = laporan.kewenanganJalan?.trim() ?? '';
    final jenis = kewenangan.toLowerCase().replaceAll('_', ' ');

    final belumPasti = jenis.isEmpty ||
        jenis == 'belum pasti' ||
        jenis == 'belum diketahui' ||
        jenis == 'perlu verifikasi' ||
        jenis == 'belum terverifikasi';

    final namaKewenangan = belumPasti
        ? 'Belum terverifikasi'
        : jenis
            .split(' ')
            .where((kata) => kata.isNotEmpty)
            .map(
              (kata) =>
                  '${kata[0].toUpperCase()}${kata.substring(1)}',
            )
            .join(' ');

    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.info_outline_rounded, 'Informasi laporan'),
          const SizedBox(height: 14),
          _infoRow(
            Icons.access_time_rounded,
            'Waktu laporan',
            laporan.waktuLaporan.trim().isNotEmpty
                ? laporan.waktuLaporan
                : '-',
            const Color(0xFF64748B),
          ),
          _infoDivider(),
          _infoRow(
            Icons.location_on_outlined,
            'Wilayah',
            laporan.wilayahNama?.trim().isNotEmpty == true
                ? laporan.wilayahNama!.trim()
                : '-',
            const Color(0xFF64748B),
          ),
          _infoDivider(),
          _infoRow(
            Icons.person_outline_rounded,
            'Pelapor',
            laporan.namaPelapor?.trim().isNotEmpty == true
                ? laporan.namaPelapor!.trim()
                : 'Warga',
            const Color(0xFF64748B),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: belumPasti
                  ? const Color(0xFFFFF8E8)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: belumPasti
                    ? const Color(0xFFF0DFB6)
                    : const Color(0xFFD8E7F8),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  size: 20,
                  color: belumPasti
                      ? const Color(0xFF946200)
                      : const Color(0xFF1769AA),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KEWENANGAN JALAN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        namaKewenangan,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172033),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        belumPasti
                            ? 'Kewenangan ruas jalan ini perlu diperiksa sebelum laporan diteruskan ke pihak terkait.'
                            : 'Pastikan kewenangan ini sesuai dengan data ruas jalan resmi.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (belumPasti)
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Color(0xFF946200),
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

  Widget _buildProgressCard() {
    final status = laporan.status.statusLabel.toLowerCase();

    final selesai = status.contains('selesai');
    final ditolak = status.contains('tolak');
    final diproses =
        status.contains('proses') || status.contains('diproses');

    final warna = selesai
        ? AppColors.greenColor
        : ditolak
            ? AppColors.redColor
            : diproses
                ? AppColors.primaryColor
                : AppColors.yellowColor;

    final warnaLatar = selesai
        ? AppColors.greenColorLight
        : ditolak
            ? AppColors.redColorLight
            : diproses
                ? AppColors.primaryColorLight
                : AppColors.yellowColorLight;

    final ikon = selesai
        ? Icons.check_circle_outline_rounded
        : ditolak
            ? Icons.cancel_outlined
            : diproses
                ? Icons.engineering_outlined
                : Icons.hourglass_empty_rounded;

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

    final catatan = laporan.catatanAdmin.trim();
    final foto = laporan.fotoBukti.trim();

    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            Icons.track_changes_outlined,
            'Status penanganan',
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: warnaLatar,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ikon, color: warna, size: 24),
                const SizedBox(width: 11),
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
                      const SizedBox(height: 5),
                      Text(
                        deskripsi,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          height: 1.6,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (catatan.isNotEmpty && !ditolak) ...[
            const SizedBox(height: 16),
            Text(
              'Catatan admin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              catatan,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.6,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
          if (foto.isNotEmpty) ...[
            const SizedBox(height: 18),
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
              borderRadius: BorderRadius.circular(12),
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
          ] else ...[
            const SizedBox(height: 14),
            Text(
              selesai
                  ? 'Foto hasil perbaikan belum tersedia.'
                  : diproses
                      ? 'Foto progres belum diunggah admin.'
                      : ditolak
                          ? 'Tidak ada foto penanganan.'
                          : 'Foto progres akan muncul setelah admin mengunggahnya.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.5,
                color: const Color(0xFF64748B),
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
              _iconBox(
                Icons.location_on_outlined,
                const Color(0xFF1769AA),
              ),
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
                    const SizedBox(height: 3),
                    Text(
                      '${laporan.latitude.toStringAsFixed(5)}, '
                      '${laporan.longitude.toStringAsFixed(5)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Salin koordinat',
                onPressed: () {
                  // Koordinat disalin melalui menu pilihan di bagian atas.
                },
                icon: const Icon(
                  Icons.place_outlined,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: IgnorePointer(
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
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 42,
                            color: laporan.status.statusColor,
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
        border: const Border(
          top: BorderSide(color: Color(0xFFE9EEF4)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _openGoogleMaps(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1769AA),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 19),
              const SizedBox(width: 9),
              Text(
                'Buka di Google Maps',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 16),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF4)),
      ),
      child: child,
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFF64748B)),
        const SizedBox(width: 9),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172033),
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 17, color: color),
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
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
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
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE9EEF4),
    );
  }

  Widget _glassCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.42),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      child: IconButton(
        onPressed: onTap,
        splashRadius: 22,
        icon: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE8EDF3),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 42,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
