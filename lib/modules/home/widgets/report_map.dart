import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';
import 'package:roadis/modules/home/widgets/section_title.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/roadis_skeleton.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';

class ReportMap extends StatelessWidget {
  const ReportMap({super.key});

  static const _defaultCenter = LatLng(-6.4731, 108.3039);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Titik rawan terdekat',
          actionLabel: 'Lihat semua',
          onAction: () => Get.toNamed(AppRoutes.maps),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Obx(() {
                if (c.isLoadingMap.value) {
                  return RoadisSkeleton(
                    enabled: true,
                    child: Skeleton.leaf(
                      child: Container(color: Colors.grey.shade300),
                    ),
                  );
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

                return Stack(
                  children: [
                    FlutterMap(
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
                    ),
                    // chip jumlah titik
                    Positioned(
                      left: 10,
                      top: 10,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 14, color: AppColors.primaryColor),
                              const SizedBox(width: 5),
                              Text(
                                '${laporan.length} titik',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: TextColors.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}