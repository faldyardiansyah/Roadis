import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';

class ReportStats extends StatelessWidget {
  const ReportStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.description_outlined,
            value: '24',
            label: 'Total Laporan',
            iconColor: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            value: '5',
            label: 'Diproses',
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            value: '18',
            label: 'Selesai',
            iconColor: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(height: 6),
          Text(
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