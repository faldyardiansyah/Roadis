import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';

class MapLaporanDetailScreen extends StatelessWidget {
  final LaporanModel laporan;

  const MapLaporanDetailScreen({super.key, required this.laporan});

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${laporan.latitude},${laporan.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // FOTO + APP BAR COLLAPSIBLE
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _glassCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'laporan-image-${laporan.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        laporan.image.isNotEmpty
                            ? Image.network(
                                laporan.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                        // Status badge glassmorphism, melayang di atas foto
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      laporan.status.statusLabel.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // KONTEN
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul
                          Text(
                            laporan.tipeKerusakan.isNotEmpty ? laporan.tipeKerusakan : laporan.judul,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0, duration: 400.ms),
                          const SizedBox(height: 4),
                          Text(
                            laporan.judul,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade600),
                          ).animate().fadeIn(duration: 400.ms, delay: 40.ms),

                          const SizedBox(height: 18),

                          // Kartu info
                          Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _infoRow(Icons.access_time_rounded, 'Waktu Laporan', laporan.waktuLaporan, const Color(0xFF6C5CE7)),
                                    _infoDivider(),
                                    _infoRow(Icons.location_on_rounded, 'Lokasi', laporan.wilayahNama ?? '-', const Color(0xFFE91E63)),
                                    _infoDivider(),
                                    _infoRow(Icons.person_outline_rounded, 'Pelapor', laporan.namaPelapor ?? 'Warga', const Color(0xFF007BFF)),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 450.ms, delay: 80.ms)
                              .slideY(begin: 0.1, end: 0, duration: 450.ms, delay: 80.ms, curve: Curves.easeOutCubic),

                          const SizedBox(height: 14),

                          // Kartu deskripsi
                          Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.notes_rounded, size: 16, color: Colors.grey.shade500),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Deskripsi',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      laporan.deskripsi.isNotEmpty ? laporan.deskripsi : 'Tidak ada deskripsi.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 450.ms, delay: 160.ms)
                              .slideY(begin: 0.1, end: 0, duration: 450.ms, delay: 160.ms, curve: Curves.easeOutCubic),

                          const SizedBox(height: 14),

                          // Kartu peta
                          Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.map_rounded, size: 16, color: Colors.grey.shade500),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Titik Lokasi',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: SizedBox(
                                        height: 170,
                                        width: double.infinity,
                                        child: IgnorePointer(
                                          child: FlutterMap(
                                            options: MapOptions(
                                              initialCenter: LatLng(laporan.latitude, laporan.longitude),
                                              initialZoom: 15,
                                              interactionOptions: const InteractionOptions(
                                                flags: InteractiveFlag.none,
                                              ),
                                            ),
                                            children: [
                                              TileLayer(
                                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                userAgentPackageName: 'com.roadis.app',
                                              ),
                                              MarkerLayer(
                                                markers: [
                                                  Marker(
                                                    point: LatLng(laporan.latitude, laporan.longitude),
                                                    width: 40,
                                                    height: 40,
                                                    child: Icon(Icons.location_on, color: color, size: 40),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 450.ms, delay: 240.ms)
                              .slideY(begin: 0.1, end: 0, duration: 450.ms, delay: 240.ms, curve: Curves.easeOutCubic),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // STICKY BOTTOM BAR
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openGoogleMaps,
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: Text(
                        'Buka di Google Maps',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 200.ms, curve: Curves.easeOutCubic),
          ),
        ],
      ),
    );
  }

  Widget _glassCircleButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey.shade500),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }
}