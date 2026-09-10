import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';

class RecentReports extends StatelessWidget {
  const RecentReports({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Kec. Indramayu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ReportCard(
          title: 'Lubang Dalam (±15cm)',
          address: 'Jl. Jatibarang, Depan SPBU',
          status: 'Diproses',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
        ),
        const SizedBox(height: 8),
        _ReportCard(
          title: 'Aspal Terkelupas',
          address: 'Jl. Raya Indramayu',
          status: 'Selesai',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String address;
  final String status;
  final IconData icon;
  final Color iconColor;

  const _ReportCard({
    required this.title,
    required this.address,
    required this.status,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: TextColors.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}