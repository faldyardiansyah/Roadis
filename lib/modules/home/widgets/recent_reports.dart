import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';
import 'package:roadis/modules/home/widgets/section_title.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/roadis_skeleton.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
              child: Column(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    const _ReportCardSkeleton(),
                  ],
                ],
              ),
            );
          }

          if (c.errorStats.value != null) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.errorStats.value!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.redAccent),
                    ),
                  ),
                  TextButton(onPressed: c.fetchRiwayat, child: const Text('Coba lagi')),
                ],
              ),
            );
          }

          final recent = c.recentReports;

          if (recent.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  children: [
                    Lottie.asset('assets/lotties/404.json', width: 260, height: 200),
                    const SizedBox(height: 4),
                    Text(
                      'Belum ada laporan. Mulai dengan melaporkan jalan rusak pertamamu.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.greyColor),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              for (int i = 0; i < recent.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _ReportCard(laporan: recent[i]),
              ],
            ],
          );
        }),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final LaporanModel laporan;

  const _ReportCard({required this.laporan});

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.22), color.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.warning_amber_rounded, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  laporan.tipeKerusakan.isNotEmpty ? laporan.tipeKerusakan : laporan.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: TextColors.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 12, color: AppColors.greyColor),
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
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  laporan.status.statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: color,
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

/// Kerangka kartu laporan saat loading (teks hanya placeholder, akan jadi bone).
class _ReportCardSkeleton extends StatelessWidget {
  const _ReportCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Skeleton.leaf(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Desa Contoh, Indramayu',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Skeleton.leaf(
            child: Container(
              width: 62,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}