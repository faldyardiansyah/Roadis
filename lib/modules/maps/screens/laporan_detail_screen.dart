import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/utils/app_colors.dart';

class LaporanDetailScreen extends StatelessWidget {
  final LaporanModel laporan;
  const LaporanDetailScreen({Key? key, required this.laporan})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    return Scaffold(
      backgroundColor: AppColors.white1Color,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          'Detail laporan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (laporan.image.isNotEmpty)
            Image.network(
              laporan.image,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _imagePlaceholder(),
            )
            else
            _imagePlaceholder(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // buat badge status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(laporan.status.statusLabel.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),

                  // ini buat judul
                  Text(laporan.tipeKerusakan.isNotEmpty ? laporan.tipeKerusakan : laporan.judul,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4,),
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}

Widget _imagePlaceholder () {
  return Container();
}
