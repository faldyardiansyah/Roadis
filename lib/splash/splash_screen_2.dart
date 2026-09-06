import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/splash_card.dart';
import 'package:roadis/utils/app_colors.dart';
// import '../login/login_screen.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Tombol Lewati
            Positioned(
              top: 16,
              right: 24,
              child: TextButton(
                onPressed: () {
                  // Get.offAllNamed(AppRoutes.login);
                },
                child: Text(
                  'Lewati',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),

            // Bagian Tengah (Icon / Lottie Halaman 2)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 180),
                child: Lottie.asset(
                  'assets/lotties/roadmap.json',
                  width: 350,
                  height: 350,
                ),
              ).animate().fadeIn(duration: 600.ms).scale(),
            ),

            // Card Bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: SplashCard(
                title: 'Pantau & Dukung',
                description: 'Lihat laporan di sekitarmu, berikan dukungan, dan pantau proses perbaikan secara real-time.',
                currentIndex: 1,
                totalPages: 2,
                onNextPressed: () {
                  // Tombol "Mulai" di halaman terakhir diarahkan ke home/login
                  // Get.offAllNamed(AppRoutes.login);
                },
              ),
            ).animate().slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}