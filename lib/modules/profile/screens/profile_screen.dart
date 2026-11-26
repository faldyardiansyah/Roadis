import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/modules/profile/controllers/profile_controller.dart';
import 'package:roadis/modules/profile/widgets/photo_options_sheet.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';
import 'package:roadis/utils/widgets/loading_overlay.dart';
import 'package:roadis/utils/widgets/roadis_skeleton.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showLogoutDialog(
    BuildContext context,
    ProfileController c,
  ) async {
    HapticFeedback.lightImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Keluar dari Akun?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kamu perlu masuk kembali untuk mengirim laporan baru atau memantau progres laporanmu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  height: 1.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Ya, Keluar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      showLoadingOverlay();
      await c.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileController());
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: RefreshIndicator(
          onRefresh: c.fetchStats,
          color: AppColors.primaryColor,
          edgeOffset: topInset + 16,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(context, c, topInset),
                const SizedBox(height: 18),
                _buildStatsCard(c),
                const SizedBox(height: 16),
                _buildMenuCard(context, c),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'ROADIS Indramayu • v2.1.0',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    ProfileController c,
    double topInset,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.midnightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: Stack(
          children: [
            Positioned.fill(
              child: BatikPattern(
                color: Colors.white,
                opacity: 0.12,
                scale: 2.4,
                fadeOut: true,
              ),
            ),
            Positioned(
              top: -8,
              right: -15,
              width: 250,
              height: 230,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.28,
                  child: Image.asset(
                    'assets/images/burung_batik.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, topInset + 14, 20, 26),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ROADIS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.80),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Profil Pengguna',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.pengaturanAkun),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                            ),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Obx(() {
                    final user = c.authC.user.value;
                    final nama = user?.nama ?? 'Warga';
                    final email = user?.email ?? '-';
                    final fotoUrl = user?.profilPhoto;

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => showPhotoOptionsSheet(c),
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.85),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 42,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      (fotoUrl != null && fotoUrl.isNotEmpty)
                                      ? NetworkImage(fotoUrl)
                                      : null,
                                  child: (fotoUrl == null || fotoUrl.isEmpty)
                                      ? Text(
                                          nama.trim().isNotEmpty
                                              ? nama.trim()[0].toUpperCase()
                                              : 'W',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryColor,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              if (c.isUploadingPhoto.value)
                                Positioned.fill(
                                  child: CircleAvatar(
                                    radius: 44,
                                    backgroundColor: Colors.black.withOpacity(
                                      0.45,
                                    ),
                                    child: const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.16),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (c.photoError.value != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            c.photoError.value!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          nama,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.30),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 13.5,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Warga Terverifikasi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.24),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 13,
                                    color: Colors.white.withOpacity(0.92),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    email,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.95),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 380.ms);
  }

  Widget _buildStatsCard(ProfileController c) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KONTRIBUSI ROADIS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (c.isLoadingStats.value) {
              return RoadisSkeleton(
                enabled: true,
                child: Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            if (c.errorStats.value != null) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      c.errorStats.value!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: c.fetchStats,
                    child: const Text('Coba lagi'),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    count: '${c.totalLaporan}',
                    label: 'Total Laporan',
                    countColor: AppColors.primaryColor,
                    bgColor: AppColors.lightIceBlue,
                    borderColor: AppColors.primaryColor.withOpacity(0.18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatItem(
                    count: '${c.totalSelesai}',
                    label: 'Selesai',
                    countColor: const Color(0xFF0E9F6E),
                    bgColor: const Color(0xFFECFDF5),
                    borderColor: const Color(0xFFA7F3D0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatItem(
                    count: '${c.totalDiproses}',
                    label: 'Diproses',
                    countColor: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                    borderColor: const Color(0xFFFDE68A),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 420.ms, delay: 80.ms).slideY(
          begin: 0.08,
          end: 0,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildMenuCard(BuildContext context, ProfileController c) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.manage_accounts_outlined,
            iconBgColor: AppColors.lightIceBlue,
            iconColor: AppColors.primaryColor,
            title: 'Pengaturan Akun & Keamanan',
            onTap: () => Get.toNamed(AppRoutes.pengaturanAkun),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_active_outlined,
            iconBgColor: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF7C3AED),
            title: 'Notifikasi & Peringatan Pengguna',
            onTap: () => Get.toNamed(AppRoutes.pengaturanNotifikasi),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.menu_book_outlined,
            iconBgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
            title: 'Panduan Penggunaan & FAQ',
            onTap: () => Get.toNamed(AppRoutes.faq),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            iconBgColor: const Color(0xFFF1F5F9),
            iconColor: const Color(0xFF475569),
            title: 'Tentang Aplikasi ROADIS',
            trailingWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'v2.1.0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            iconBgColor: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFDC2626),
            title: 'Keluar dari Akun',
            isDanger: true,
            onTap: () => _showLogoutDialog(context, c),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 420.ms, delay: 160.ms).slideY(
          begin: 0.08,
          end: 0,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildStatItem({
    required String count,
    required String label,
    required Color countColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: countColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    Widget? trailingWidget,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDanger
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else
              Icon(
                Icons.chevron_right_rounded,
                color: isDanger
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF94A3B8),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 16,
      endIndent: 16,
    );
  }
}
