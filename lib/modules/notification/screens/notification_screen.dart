import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Notifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.checklist_sharp,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fade(duration: 400.ms)
                .slideY(begin: -0.2, end: 0, duration: 400.ms),

            const SizedBox(height: 20),

            // HEADER NOTIFIKASI TERBARU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Notifikasi Terbaru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    icon: const Icon(
                      Icons.checklist_sharp,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    label: Text(
                      'Tandai Semua Dibaca',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 500.ms, delay: 150.ms),

            const SizedBox(height: 8),

            // FILTER BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButtonFilter(Icons.all_inbox, 'Semua', true, () {}),
                _buildButtonFilter(
                  Icons.calendar_month,
                  'Hari Ini',
                  false,
                  () {},
                ),
                _buildButtonFilter(
                  Icons.calendar_month,
                  'Kemarin',
                  false,
                  () {},
                ),
              ],
            )
                .animate()
                .fade(duration: 500.ms, delay: 250.ms)
                .slideX(begin: 0.1, end: 0, duration: 500.ms),

            const SizedBox(height: 12),

            // LIST NOTIFIKASI
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                children: [
                  _buildListNotifikasi(
                    Icons.sync_rounded,
                    'Laporan sedang diproses',
                    'Laporan kerusakan jalan sedang diperiksa oleh petugas.',
                    'Diproses',
                    Colors.orange,
                    '10 menit yang lalu',
                    () {},
                  ),
                  _buildListNotifikasi(
                    Icons.verified_rounded,
                    'Laporan telah selesai',
                    'Laporan kerusakan jalan berhasil ditindaklanjuti.',
                    'Selesai',
                    Colors.green,
                    '1 jam yang lalu',
                    () {},
                  ),
                  _buildListNotifikasi(
                    Icons.location_on_rounded,
                    'Laporan berhasil dikirim',
                    'Laporan kerusakan jalan kamu berhasil diterima.',
                    'Info',
                    Colors.blue,
                    '2 jam yang lalu',
                    () {},
                  ),
                  _buildListNotifikasi(
                    Icons.sync_rounded,
                    'Laporan sedang ditinjau',
                    'Petugas sedang melakukan pemeriksaan laporan kamu.',
                    'Diproses',
                    Colors.orange,
                    'Kemarin',
                    () {},
                  ),
                  _buildListNotifikasi(
                    Icons.verified_rounded,
                    'Laporan selesai ditangani',
                    'Kerusakan jalan yang kamu laporkan telah diperbaiki.',
                    'Selesai',
                    Colors.green,
                    'Kemarin',
                    () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                '$currentYear Developer Roadis',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// --- HELPER METHODS ---

Widget _buildButtonFilter(
  IconData icon,
  String label,
  bool isSelected,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black54,
            size: 12,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildListNotifikasi(
  IconData icon,
  String title,
  String subtitle,
  String status,
  Color statusColor,
  String time,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9EEF3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ).animate().fade(duration: 500.ms).slideY(begin: 0.15, end: 0, duration: 500.ms);
}