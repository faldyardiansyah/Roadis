import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';

class MapLaporanDetailScreen extends StatelessWidget {
  final LaporanModel laporan;

  const MapLaporanDetailScreen({super.key, required this.laporan});

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          'Detail Laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto laporan
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
                  // Badge status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      laporan.status.statusLabel.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Judul / tipe kerusakan
                  Text(
                    laporan.tipeKerusakan.isNotEmpty ? laporan.tipeKerusakan : laporan.judul,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    laporan.judul,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info rows
                  _infoRow(Icons.access_time_rounded, 'Waktu Laporan', laporan.waktuLaporan),
                  const SizedBox(height: 10),
                  _infoRow(Icons.location_on_rounded, 'Lokasi', laporan.wilayahNama ?? '-'),
                  const SizedBox(height: 10),
                  _infoRow(Icons.person_outline_rounded, 'Pelapor', laporan.namaPelapor ?? 'Warga'),
                  const SizedBox(height: 16),

                  // Deskripsi
                  Text(
                    'Deskripsi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    laporan.deskripsi.isNotEmpty ? laporan.deskripsi : 'Tidak ada deskripsi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mini map lokasi
                  Text(
                    'Titik Lokasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 160,
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
                                  width: 36,
                                  height: 36,
                                  child: Icon(Icons.location_on, color: color, size: 36),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.grey.shade200,
      child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey.shade400),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}