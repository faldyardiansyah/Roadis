import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';

class ReportMap extends StatelessWidget {
  const ReportMap({super.key});

  static const _defaultCenter = LatLng(-6.4731, 108.3039);

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
              'Titik Rawan Terdekat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TextColors.primaryTextColor,
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Get.toNamed(AppRoutes.maps);
              },
              child: Text(
                'Lihat Semua >',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 125,
            width: double.infinity,
            child: Obx(() {
              if (c.isLoadingMap.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.errorMap.value != null) {
                return Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: TextButton.icon(
                      onPressed: c.fetchPeta,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Muat ulang peta'),
                    ),
                  ),
                );
              }

              final laporan = c.petaLaporan;
              final center = laporan.isNotEmpty
                  ? LatLng(laporan.first.latitude, laporan.first.longitude)
                  : _defaultCenter;

              return FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.roadis.app',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final lap in laporan)
                        Marker(
                          point: LatLng(lap.latitude, lap.longitude),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: lap.status.statusColor,
                            size: 35,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}