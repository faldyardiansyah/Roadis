import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';

class ServiceBanner extends StatelessWidget {
  const ServiceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -25,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PELAYANAN WARGA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: TextColors.whiteTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Laporan Jalan Rusak di Sekitarmu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: TextColors.whiteTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bantu wujudkan jalanan Indramayu yang aman dan mulus bersama JalanKu.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: TextColors.whiteTextColor,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whiteColor,
                  foregroundColor: AppColors.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lapor Sekarang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}