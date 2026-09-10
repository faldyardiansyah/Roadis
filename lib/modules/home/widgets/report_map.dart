import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';

class ReportMap extends StatelessWidget {
  const ReportMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Titik Rawan Terdekat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TextColors.primaryTextColor,
              ),
            ),
            Text(
              'Lihat Semua >',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 125,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffedf3f7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 35,
                top: 25,
                child: _MapMarker(
                  color: Colors.red,
                  label: 'Jl. Raya Jatibarang',
                ),
              ),
              Positioned(
                right: 35,
                bottom: 30,
                child: _MapMarker(
                  color: Colors.orange,
                  label: 'Jl. Pantura',
                ),
              ),
              Positioned(
                left: 15,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '• 1.2 km dari lokasimu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  final Color color;
  final String label;

  const _MapMarker({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(
          Icons.location_on,
          color: color,
          size: 25,
        ),
      ],
    );
  }
}