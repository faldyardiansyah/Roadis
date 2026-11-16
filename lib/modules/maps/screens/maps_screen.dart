import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/location_service.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';
import '../controllers/maps_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _c = Get.put(MapsController());

  final LatLng _indramayuCenter = const LatLng(-6.4731, 108.3039);
  LatLng? _currentLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    // Setiap kali searchQuery berubah, cek hasil filter dan geser peta
    ever(_c.searchQuery, (_) => _moveToFirstResult());
    _initUserLocation();
  }

  Future<void> _initUserLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null && mounted) {
        final userPoint = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentLocation = userPoint;
        });
        _mapController.move(userPoint, 16.0);
      }
    } catch (_) {
      // Abaikan jika GPS gagal di awal
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _moveToUserLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16.0);
      return;
    }

    setState(() => _isLocating = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null && mounted) {
        final userPoint = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentLocation = userPoint;
        });
        _mapController.move(userPoint, 16.0);
      } else {
        _mapController.move(_indramayuCenter, 15.0);
      }
    } catch (_) {
      _mapController.move(_indramayuCenter, 15.0);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _moveToFirstResult() {
    if (_c.filteredLaporan.isEmpty) return;

    final firstResult = _c.filteredLaporan.first;
    _mapController.move(
      LatLng(firstResult.latitude, firstResult.longitude),
      16.0,
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Peta Laporan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _c.resetFilters();
                    Get.back();
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Status Laporan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final filter in MapsController.filterOptions)
                      _buildModernFilterChip(
                        filter,
                        _c.selectedFilter.value == filter,
                        () => _c.selectFilter(filter),
                      ),
                  ],
                )),
            const SizedBox(height: 18),
            Text(
              'Kewenangan Jalan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final kw in MapsController.kewenanganOptions)
                      _buildModernFilterChip(
                        kw == 'Semua' ? 'Semua Kewenangan' : 'Jalan $kw',
                        _c.selectedKewenangan.value == kw,
                        () => _c.selectKewenangan(kw),
                        accentColor: const Color(0xFF0D9488),
                      ),
                  ],
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Terapkan Filter',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildModernFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color accentColor = const Color(0xFF0284C7),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              if (_c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_c.errorMessage.value != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _c.errorMessage.value!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _c.fetchLaporan,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                );
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _indramayuCenter,
                  initialZoom: 15.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.jalanku.indramayu',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_currentLocation != null)
                        Marker(
                          point: _currentLocation!,
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      for (final lap in _c.filteredLaporan)
                        Marker(
                          point: LatLng(lap.latitude, lap.longitude),
                          width: 36,
                          height: 36,
                          child: GestureDetector(
                            onTap: () => _c.selectLaporan(lap),
                            child: Container(
                              decoration: BoxDecoration(
                                color: lap.status.statusColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),

            // APP BAR SEARCH & FILTER
            Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.grey.shade400,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _c.searchQuery.value,
                                      onChanged: _c.updateSearch,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Cari lokasi...',
                                        hintStyle: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            final hasActiveFilter = _c.selectedFilter.value != 'Semua' ||
                                _c.selectedKewenangan.value != 'Semua';
                            return InkWell(
                              onTap: _showFilterBottomSheet,
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: hasActiveFilter
                                      ? const Color(0xFF0284C7)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: hasActiveFilter
                                          ? const Color(0x330284C7)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      color: hasActiveFilter
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      size: 20,
                                    ),
                                    if (hasActiveFilter)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.amber,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              for (final filter in MapsController.filterOptions)
                                _buildFilterChip(
                                  filter == 'Semua' ? 'Semua (${_c.semuaLaporan.length})' : filter,
                                  _c.selectedFilter.value == filter,
                                  () => _c.selectFilter(filter),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(
                  begin: -0.2,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),

            // MAP CONTROLS
            Positioned(
                  right: 16,
                  top: 130,
                  child: Column(
                    children: [
                      _buildMapButton(
                        _isLocating ? Icons.hourglass_top_rounded : Icons.my_location,
                        _moveToUserLocation,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade200,
                            ),
                            InkWell(
                              onTap: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.easeOutCubic,
                ),

            // DETAIL CARD
            Obx(() {
              final lap = _c.selectedLaporan.value;
              if (lap == null) return const SizedBox.shrink();

              return Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: _DetailCard(
                      laporan: lap,
                      onClose: _c.closeDetailCard,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0284C7) : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0x330284C7)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.black87),
        onPressed: onTap,
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback onClose;

  const _DetailCard({required this.laporan, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    Future<void> _openNavigation() async {
      final lat = laporan.latitude;
      final lng = laporan.longitude;

      final googleMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );

      try {
        final opened = await launchUrl(
          googleMapsUri,
          mode: LaunchMode.externalApplication,
        );

        if (!opened) {
          showAwesomeSnackbar(
            title: 'Terjadi Kesalahan',
            message: 'Gagal membuka Google Maps.',
            contentType: ContentType.failure,
          );
        }
      } catch (_) {
        showAwesomeSnackbar(
          title: 'Terjadi Kesalahan',
          message: 'Gagal membuka Google Maps.',
          contentType: ContentType.failure,
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: color,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            laporan.status.statusLabel.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            laporan.waktuLaporan,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      laporan.tipeKerusakan.isNotEmpty
                          ? laporan.tipeKerusakan
                          : laporan.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            laporan.wilayahNama ?? laporan.judul,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.close_rounded, size: 20, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.detailMaps, arguments: laporan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    'Lihat Rincian Laporan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: _openNavigation,
                  icon: const Icon(
                    Icons.navigation_rounded,
                    size: 15,
                    color: Color(0xFF0284C7),
                  ),
                  label: Text(
                    'Navigasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF0284C7).withOpacity(0.35)),
                    backgroundColor: const Color(0xFF0284C7).withOpacity(0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
