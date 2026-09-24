import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';

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

      return Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.description_outlined,
              value: loading ? '-' : '${c.totalLaporan}',
              label: 'Total Laporan',
              iconColor: AppColors.primaryColor,
              loading: loading,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              icon: Icons.access_time,
              value: loading ? '-' : '${c.totalDiproses}',
              label: 'Diproses',
              iconColor: Colors.orange,
              loading: loading,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              value: loading ? '-' : '${c.totalSelesai}',
              label: 'Selesai',
              iconColor: Colors.green,
              loading: loading,
            ),
          ),
        ],
      );
    });
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
        borderRadius: BorderRadius.circular(10),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final bool loading;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TextColors.primaryTextColor,
                  ),
                ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}