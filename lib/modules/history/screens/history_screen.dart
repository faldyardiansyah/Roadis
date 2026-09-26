import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import '../controllers/history_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _c = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riwayat Laporan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pantau status perbaikan jalan Anda di sini',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 1,
                        shadowColor: Colors.black.withOpacity(0.05),
                        child: InkWell(
                          onTap: () => Get.toNamed(AppRoutes.notifikasi),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 22,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 16),

            // Search Bar
            Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: _c.updateSearch,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Cari nomor tiket atau lokasi...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 100.ms, duration: 500.ms)
                .slideY(begin: -0.1, end: 0),

            const SizedBox(height: 16),

            // Filter Chips
            SizedBox(
              height: 38,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() {
                  return Row(
                    children: HistoryController.filterOptions.map((filter) {
                      final isSelected = _c.selectedFilter.value == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _c.selectFilter(filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0284C7)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0284C7,
                                        ).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              '$filter (${_c.countFor(filter)})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

            const SizedBox(height: 12),

            // List Laporan
            Expanded(
              child: Obx(() {
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
                          onPressed: _c.fetchRiwayat,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final list = _c.filteredLaporan;

                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada laporan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _c.fetchRiwayat,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(
                        laporan: list[index],
                        index: index,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({required LaporanModel laporan, required int index}) {
    final statusLower = laporan.status.toLowerCase();
    final showQueueInfo = statusLower == 'menunggu' || statusLower == 'proses';

    return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '#JK-${laporan.id}  •  ${laporan.waktuLaporan}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: laporan.status.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      laporan.status.statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: laporan.status.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                laporan.tipeKerusakan.isNotEmpty
                    ? laporan.tipeKerusakan
                    : laporan.judul,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Colors.pinkAccent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      laporan.wilayahNama ?? laporan.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              if (showQueueInfo) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Menunggu perbaikan jalan oleh dinas terkait',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + (index * 60)),
          duration: 500.ms,
        )
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}
