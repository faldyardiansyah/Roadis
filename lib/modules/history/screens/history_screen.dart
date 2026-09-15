import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Laporan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.notifications_none, color: Colors.grey.shade700),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari nomor tiket atau lokasi...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.tune, size: 18, color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip('Semua (24)', true),
                  _filterChip('Diproses (5)', false),
                  _filterChip('Selesai (18)', false),
                  _filterChip('Ditolak (1)', false),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List laporan
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildReportCard(
                    nomor: '#JK-8821',
                    waktu: '15 Menit lalu',
                    status: 'Rusak Berat',
                    statusColor: Colors.red,
                    judul: 'Lubang Jalan Dalam (±15cm)',
                    lokasi: 'Jl. Raya Jatibarang (Depan SPBU)',
                    proses: true,
                  ),

                  _buildReportCard(
                    nomor: '#JK-8754',
                    waktu: '2 Hari lalu',
                    status: 'Selesai Diperbaiki',
                    statusColor: Colors.green,
                    judul: 'Jalan Amblas & Retak Panjang',
                    lokasi: 'Jl. Sudirman, Sindang, Indramayu',
                    proses: false,
                  ),

                  _buildReportCard(
                    nomor: '#JK-8690',
                    waktu: '5 Hari lalu',
                    status: 'Dalam Antrean',
                    statusColor: Colors.blue,
                    judul: 'Lampu Jalan Mati & Aspal Bergelombang',
                    lokasi: 'Jl. Pantura Kandhangaur',
                    proses: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter
  Widget _filterChip(String text, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0284C7) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFF0284C7) : Colors.grey.shade200,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }

  // Card laporan
  Widget _buildReportCard({
    required String nomor,
    required String waktu,
    required String status,
    required Color statusColor,
    required String judul,
    required String lokasi,
    required bool proses,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor dan status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$nomor • $waktu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  color: Colors.grey.shade500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Judul
          Text(
            judul,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 5),

          // Lokasi
          Row(
            children: [
              const Icon(Icons.location_on, size: 13, color: Colors.pink),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  lokasi,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          if (proses) ...[
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 15, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Menunggu perbaikan jalan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusIcon(IconData icon, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 12, color: Colors.white),
    );
  }
}
