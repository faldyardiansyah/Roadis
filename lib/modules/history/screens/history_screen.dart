import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';
import 'package:roadis/utils/widgets/roadis_skeleton.dart';
import '../controllers/history_controller.dart';
import 'detail_laporan_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _c = Get.put(HistoryController());
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF5F7FB),
        body: Column(
          children: [
            _buildCurvedHeader(topInset),
            const SizedBox(height: 14),
            _buildFilterChips(),
            const SizedBox(height: 10),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedHeader(double topInset) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, Color(0xFF0096C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Stack(
          children: [
            Positioned.fill(
              child: BatikPattern(
                color: Colors.white,
                opacity: 0.10,
                scale: 2.2,
                fadeOut: true,
              ),
            ),
            Positioned(
              right: -2,
              width: 175,
              height: 155,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/images/burung_batik.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, topInset + 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Riwayat Laporan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Pantau progres laporan jalan Anda',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.86),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Get.toNamed(AppRoutes.notifikasi),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.28),
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 380.ms).slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 16),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _c.updateSearch,
                            maxLines: 1,
                            textAlignVertical: TextAlignVertical.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari tiket #RD, kerusakan, atau lokasi...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Obx(() {
                          if (_c.searchQuery.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _c.updateSearch('');
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ).animate().fadeIn(delay: 80.ms, duration: 380.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _c.selectFilter(filter);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.28),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      '$filter (${_c.countFor(filter)})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
    ).animate().fadeIn(delay: 140.ms, duration: 380.ms);
  }

  Widget _buildBody() {
    return Obx(() {
      if (_c.isLoading.value) {
        return RoadisSkeleton(
          enabled: true,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            itemCount: 4,
            itemBuilder: (_, __) => _buildSkeletonCard(),
          ),
        );
      }

      if (_c.errorMessage.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 30,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _c.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _c.fetchRiwayat,
                  icon: const Icon(Icons.refresh_rounded, size: 17, color: Colors.white),
                  label: Text(
                    'Coba Lagi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final list = _c.filteredLaporan;

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lotties/404.json',
                  width: 220,
                  height: 180,
                ),
                const SizedBox(height: 6),
                Text(
                  'Belum ada laporan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Laporan yang kamu kirim atau sesuai pencarian akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
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
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _buildReportCard(laporan: list[index], index: index);
          },
        ),
      );
    });
  }

  Widget _buildReportCard({required LaporanModel laporan, required int index}) {
    final statusColor = laporan.status.statusColor;
    final adaCatatanAdmin = laporan.catatanAdmin.trim().isNotEmpty;
    final title = laporan.tipeKerusakan.isNotEmpty
        ? laporan.tipeKerusakan
        : laporan.judul;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Get.to(
          () => DetailLaporanScreen(laporan: laporan),
          transition: Transition.rightToLeft,
          duration: 300.ms,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoThumbnail(laporan.image, statusColor),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightIceBlue,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '#RD-${laporan.id}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              laporan.status.statusLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13.5,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          laporan.wilayahNama ?? laporan.judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          laporan.waktuLaporan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      if (adaCatatanAdmin) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 10.5,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Balasan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(
            delay: Duration(milliseconds: 40 * index.clamp(0, 8)),
            duration: 360.ms,
          ).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildPhotoThumbnail(String imageUrl, Color statusColor) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 92,
        height: 106,
        color: AppColors.lightIceBlue,
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor.withOpacity(0.5),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _photoPlaceholder(statusColor),
              )
            : _photoPlaceholder(statusColor),
      ),
    );
  }

  Widget _photoPlaceholder(Color statusColor) {
    return Container(
      color: AppColors.lightIceBlue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_road_rounded,
            size: 28,
            color: AppColors.primaryColor.withOpacity(0.55),
          ),
          const SizedBox(height: 4),
          Text(
            'No Foto',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 106,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 55, height: 18, color: Colors.grey.shade200),
                    const Spacer(),
                    Container(width: 65, height: 18, color: Colors.grey.shade200),
                  ],
                ),
                const SizedBox(height: 10),
                Container(width: double.infinity, height: 14, color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(width: 150, height: 12, color: Colors.grey.shade200),
                const SizedBox(height: 14),
                Container(width: 100, height: 10, color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
