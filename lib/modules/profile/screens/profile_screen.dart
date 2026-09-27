import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/widgets/loading_overlay.dart';
import 'package:roadis/modules/profile/controllers/profile_controller.dart';
import 'package:roadis/modules/profile/widgets/photo_options_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: c.fetchStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  color: AppColors.whiteColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
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
                              color: AppColors.greyColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Profil Pengguna',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: TextColors.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: AppColors.blackColor,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // bagian identitas
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Obx(() {
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
                              CircleAvatar(
                                radius: 42,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                                    ? NetworkImage(fotoUrl)
                                    : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                              ),
                              if (c.isUploadingPhoto.value)
                                Positioned.fill(
                                  child: CircleAvatar(
                                    radius: 42,
                                    backgroundColor: Colors.black.withOpacity(0.4),
                                    child: const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                  ),
                                ),
                              Positioned(
                                right: 0,
                                bottom: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 20,
                                    color: Color(0xFF007BFF),
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
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          nama,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TextColors.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFA3E6C5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, size: 14, color: Color(0xFF0E9F6E)),
                              const SizedBox(width: 6),
                              Text(
                                'Warga Terverifikasi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0E9F6E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                email,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 600.ms, delay: 100.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // kontribusinya
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'KONTRIBUSI ROADIS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (c.isLoadingStats.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (c.errorStats.value != null) {
                          return Column(
                            children: [
                              Text(
                                c.errorStats.value!,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.redAccent),
                              ),
                              TextButton(onPressed: c.fetchStats, child: const Text('Coba lagi')),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                count: '${c.totalLaporan}',
                                label: 'Total Laporan',
                                countColor: const Color(0xFF007BFF),
                                bgColor: const Color(0xFFEBF3FF),
                                borderColor: const Color(0xFFBFDBFE),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatItem(
                                count: '${c.totalSelesai}',
                                label: 'Selesai',
                                countColor: const Color(0xFF0E9F6E),
                                bgColor: const Color(0xFFE8F8F1),
                                borderColor: const Color(0xFFA7E3C8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatItem(
                                count: '${c.totalDiproses}',
                                label: 'Diproses',
                                countColor: Colors.orange.shade700,
                                bgColor: const Color(0xFFFFF4E5),
                                borderColor: const Color(0xFFFED7AA),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOutCubic);
                      }),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // MENU
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        iconBgColor: const Color(0xFFEBF3FF),
                        iconColor: const Color(0xFF007BFF),
                        title: 'Pengaturan Akun & Keamanan',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        iconBgColor: const Color(0xFFEEECFF),
                        iconColor: const Color(0xFF6C5CE7),
                        title: 'Notifikasi & Peringatan Kerusakan',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.menu_book_outlined,
                        iconBgColor: const Color(0xFFE6F7F5),
                        iconColor: const Color(0xFF00B894),
                        title: 'Panduan Penggunaan & FAQ',
                        onTap: () {
                          Get.toNamed(AppRoutes.faq);
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        iconBgColor: const Color(0xFFF2F4F7),
                        iconColor: Colors.grey.shade700,
                        title: 'Tentang Aplikasi ROADIS',
                        trailingWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'v2.1.0',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        iconBgColor: const Color(0xFFFFEBEE),
                        iconColor: Colors.red,
                        title: 'Keluar dari Akun',
                        isDanger: true,
                        onTap: () async {
                          showLoadingOverlay();
                          await c.logout();
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.15, end: 0, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Roadis Developer 2026',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
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
            fontWeight: FontWeight.bold,
            color: countColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
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
    String? subtitle,
    Widget? trailingWidget,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? Colors.red : TextColors.primaryTextColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF007BFF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else
              Icon(
                Icons.chevron_right_rounded,
                color: isDanger ? Colors.red : Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 16,
      endIndent: 16,
    );
  }
  }