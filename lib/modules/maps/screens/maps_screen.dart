import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import '../controllers/maps_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _c = Get.put(MapsController());

  final LatLng _indramayuCenter = const LatLng(-6.4731, 108.3039);

    @override
  void initState() {
    super.initState();
    // Setiap kali searchQuery berubah, cek hasil filter dan geser peta
    ever(_c.searchQuery, (_) => _moveToFirstResult());
  }

  void _moveToFirstResult() {
    if (_c.searchQuery.value.trim().isEmpty) return;
    final hasil = _c.filteredLaporan;
    if (hasil.isNotEmpty) {
      _mapController.move(
        LatLng(hasil.first.latitude, hasil.first.longitude),
        16,
      );
    }
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
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _c.fetchLaporan, child: const Text('Coba lagi')),
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
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.jalanku.indramayu',
                  ),
                  MarkerLayer(
                    markers: [
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
                                border: Border.all(color: Colors.white, width: 2),
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
                              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                  Icon(Icons.search, color: Colors.grey.shade400, size: 18),
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
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(Icons.tune_rounded, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final filter in MapsController.filterOptions)
                                _buildFilterChip(
                                  '$filter (${_c.countFor(filter)})',
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
                .slideY(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

            // MAP CONTROLS
            Positioned(
                  right: 16,
                  top: 130,
                  child: Column(
                    children: [
                      _buildMapButton(Icons.my_location, () {
                        _mapController.move(_indramayuCenter, 15);
                      }),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
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
                                child: Icon(Icons.add, size: 20, color: Colors.black87),
                              ),
                            ),
                            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                            InkWell(
                              onTap: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.remove, size: 20, color: Colors.black87),
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
                .slideX(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOutCubic),

            // DETAIL CARD
            Obx(() {
              final lap = _c.selectedLaporan.value;
              if (lap == null) return const SizedBox.shrink();

              return Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: _DetailCard(laporan: lap, onClose: _c.closeDetailCard),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0284C7) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning_amber_rounded, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            laporan.status.statusLabel.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            laporan.waktuLaporan,
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      laporan.tipeKerusakan.isNotEmpty ? laporan.tipeKerusakan : laporan.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            laporan.wilayahNama ?? laporan.judul,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onClose,
                child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: arahkan ke halaman detail laporan kalau sudah ada
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Lihat Rincian Laporan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: buka aplikasi navigasi (misal geo: URI atau Google Maps)
                  },
                  icon: const Icon(Icons.navigation_outlined, size: 14, color: Color(0xFF0284C7)),
                  label: Text(
                    'Navigasi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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