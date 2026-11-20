import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/roadis_skeleton.dart';

class ReportStats extends StatelessWidget {
  const ReportStats({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Obx(() {
      final loading = c.isLoadingStats.value;
      final error = c.errorStats.value;

      if (error != null) {
        return _ErrorRow(message: error, onRetry: c.fetchRiwayat);
      }

      return RoadisSkeleton(
        enabled: loading,
        child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.description_rounded,
              value: loading ? '00' : '${c.totalLaporan}',
              label: 'Total laporan',
              color: AppColors.primaryColor,
              loading: loading,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.hourglass_bottom_rounded,
              value: loading ? '00' : '${c.totalDiproses}',
              label: 'Diproses',
              color: const Color(0xFFF59E0B),
              loading: loading,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_rounded,
              value: loading ? '00' : '${c.totalSelesai}',
              label: 'Selesai',
              color: const Color(0xFF22C55E),
              loading: loading,
            ),
          ),
        ],
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool loading;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.16), color.withOpacity(0.06)],
        ),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w800,
              color: TextColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRow({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              message,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.redAccent),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}