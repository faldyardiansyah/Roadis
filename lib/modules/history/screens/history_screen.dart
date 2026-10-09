import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import '../controllers/history_controller.dart';
import 'detail_laporan_screen.dart';

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
                            'Pantau status laporan jalan Anda',
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
                            maxLines: 1,
                            textAlignVertical: TextAlignVertical.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Cari nomor tiket atau lokasi...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
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
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (_c.errorMessage.value != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 42,
                          color: AppColors.lightGreyColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _c.errorMessage.value!,
                          textAlign: TextAlign.center,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/lotties/404.json',
                            width: 250,
                            height: 200,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Belum ada laporan.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.greyColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Laporan yang kamu kirim akan muncul di sini.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.lightGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _c.fetchRiwayat,
                  color: AppColors.primaryColor,
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
    final status = laporan.status.toLowerCase().trim();

    final isMenunggu =
        status == 'menunggu' ||
        status == 'menunggu_verifikasi' ||
        status == 'menunggu verifikasi';

    final isDiproses =
        status == 'proses' ||
        status == 'diproses' ||
        status == 'sedang diproses';

    final isSelesai = status == 'selesai';
    final isDitolak = status == 'ditolak';

    final statusColor = laporan.status.statusColor;

    final String pesanStatus;
    final String judulStatus;
    final IconData ikonStatus;
    final Color warnaInfo;
    final Color warnaLatar;

    if (isMenunggu) {
      judulStatus = 'Menunggu Verifikasi Admin';
      pesanStatus =
          'Laporan berhasil dikirim dan sedang menunggu pemeriksaan admin.';
      ikonStatus = Icons.hourglass_top_rounded;
      warnaInfo = const Color(0xFFB45309);
      warnaLatar = const Color(0xFFFFFBEB);
    } else if (isDiproses) {
      judulStatus = 'Laporan Sedang Diproses';
      pesanStatus = 'Laporan kamu sedang ditindaklanjuti oleh dinas terkait.';
      ikonStatus = Icons.engineering_outlined;
      warnaInfo = const Color(0xFF1D4ED8);
      warnaLatar = const Color(0xFFEFF6FF);
    } else if (isSelesai) {
      judulStatus = 'Penanganan Selesai';
      pesanStatus = 'Laporan ini telah dinyatakan selesai oleh admin.';
      ikonStatus = Icons.check_circle_outline_rounded;
      warnaInfo = const Color(0xFF15803D);
      warnaLatar = const Color(0xFFF0FDF4);
    } else if (isDitolak) {
      judulStatus = 'Laporan Ditolak';
      pesanStatus = 'Buka detail laporan untuk melihat keterangan dari admin.';
      ikonStatus = Icons.info_outline_rounded;
      warnaInfo = const Color(0xFFB91C1C);
      warnaLatar = const Color(0xFFFEF2F2);
    } else {
      judulStatus = laporan.status.statusLabel;
      pesanStatus = 'Buka detail untuk melihat perkembangan laporan.';
      ikonStatus = Icons.info_outline_rounded;
      warnaInfo = AppColors.greyColor;
      warnaLatar = const Color(0xFFF8FAFC);
    }

    // Catatan admin akan terlihat jika tersedia di model.
    final catatanAdmin = laporan.catatanAdmin.trim();
    final adaCatatanAdmin = catatanAdmin.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => DetailLaporanScreen(laporan: laporan),
          transition: Transition.rightToLeft,
        );
      },
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.035),
                      blurRadius: 12,
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
                                size: 13,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '#JK-${laporan.id} • ${laporan.waktuLaporan}',
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
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            laporan.status.statusLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      laporan.tipeKerusakan.isNotEmpty
                          ? laporan.tipeKerusakan
                          : laporan.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: Colors.pinkAccent,
                        ),
                        const SizedBox(width: 5),
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

                    const SizedBox(height: 14),

                    // Informasi status laporan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: warnaLatar,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: warnaInfo.withOpacity(0.12)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(ikonStatus, size: 19, color: warnaInfo),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  judulStatus,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: warnaInfo,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pesanStatus,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    height: 1.5,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Indikator jika admin sudah memberi catatan
                    if (adaCatatanAdmin) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.mark_chat_unread_outlined,
                              size: 17,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ada catatan dari admin. Ketuk untuk membaca.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Lihat detail',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 100 + (index * 60)),
                duration: 500.ms,
              )
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
    );
  }
}
