import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';
import 'package:roadis/modules/home/models/laporan_model.dart';

class RecentReports extends StatelessWidget {
  const RecentReports({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Laporan Terbaru',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TextColors.primaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (c.isLoadingStats.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (c.errorStats.value != null) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(10),
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
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'Belum ada laporan.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.greyColor),
              ),
            );
          }

          return Column(
            children: [
              for (int i = 0; i < recent.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: laporan.status.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: laporan.status.statusColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  laporan.tipeKerusakan.isNotEmpty ? laporan.tipeKerusakan : laporan.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: TextColors.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  laporan.wilayahNama ?? laporan.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: laporan.status.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              laporan.status.statusLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: laporan.status.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}