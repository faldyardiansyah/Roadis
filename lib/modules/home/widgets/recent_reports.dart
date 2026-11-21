import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/modules/history/screens/detail_laporan_screen.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';
import 'package:roadis/modules/home/widgets/section_title.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/roadis_skeleton.dart';
import 'package:skeletonizer/skeletonizer.dart';

String _judulOf(LaporanModel l) =>
    l.tipeKerusakan.isNotEmpty ? l.tipeKerusakan : l.judul;

class RecentReports extends StatelessWidget {
  const RecentReports({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Laporan terbaru'),
        const SizedBox(height: 12),
        Obx(() {
          if (c.isLoadingStats.value) {
            return RoadisSkeleton(
              enabled: true,
              child: _ListCard(
                children: [for (int i = 0; i < 3; i++) const _TileSkeleton()],
              ),
            );
          }

          if (c.errorStats.value != null) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.errorStats.value!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: c.fetchRiwayat,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final recent = c.recentReports;

          if (recent.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/lotties/404.json',
                      width: 240,
                      height: 180,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Belum ada laporan. Mulai dengan melaporkan jalan rusak pertamamu.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return _ListCard(
            children: [for (final l in recent) _ReportTile(laporan: l)],
          );
        }),
      ],
    );
  }
}

/// Kartu putih berisi daftar, dipisah garis tipis seperti riwayat transaksi.
class _ListCard extends StatelessWidget {
  final List<Widget> children;

  const _ListCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          const Divider(
            height: 1,
            thickness: 1,
            indent: 88,
            endIndent: 16,
            color: Color(0xFFF0F2F7),
          ),
        );
      }
      rows.add(children[i]);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.white,
          child: Column(children: rows),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final LaporanModel laporan;

  const _ReportTile({required this.laporan});

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    return InkWell(
      // Buka halaman detail yang sudah ada
      onTap: () => Get.to(
        () => DetailLaporanScreen(laporan: laporan),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _Thumb(url: laporan.image, color: color, size: 60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _judulOf(laporan),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: TextColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 12,
                        color: AppColors.greyColor,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          laporan.wilayahNama ?? laporan.judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusChip(
                        label: laporan.status.statusLabel,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          laporan.waktuLaporan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  final Color color;
  final double size;

  const _Thumb({required this.url, required this.color, required this.size});

  Widget _placeholder() => Container(
    color: color.withOpacity(0.12),
    alignment: Alignment.center,
    child: Icon(Icons.add_road_rounded, size: size * 0.42, color: color),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? _placeholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _placeholder(),
              ),
      ),
    );
  }
}

/// Kerangka baris saat loading (teks hanya placeholder, jadi bone).
class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Skeleton.leaf(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jalan berlubang besar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Desa Contoh, Indramayu',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5),
                ),
                const SizedBox(height: 8),
                Skeleton.leaf(
                  child: Container(
                    width: 64,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
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
}