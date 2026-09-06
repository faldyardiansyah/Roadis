import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/splash_card.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'splash_screen_2.dart';
import 'package:roadis/routes/app_routes.dart';

class SplashScreen1 extends StatelessWidget {
  const SplashScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 24,
              child: TextButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.login);
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

            // Bagian Tengah (Icon / Lottie Halaman 1)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 180),
                child: Lottie.asset(
                  'assets/lotties/splash1.json',
                  width: 350,
                  height: 350,
                ),
              ).animate().fadeIn(duration: 600.ms).scale(),
            ),

            // Card Bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: SplashCard(
                title: 'Foto & Laporkan Rusak',
                description: 'Ambil foto kerusakan jalan dan biarkan kecerdasan buatan menganalisis jenis serta tingkat kerusakannya.',
                currentIndex: 0,
                totalPages: 2,
                onNextPressed: () {
                  Get.to(() => const SplashScreen2(), transition: Transition.rightToLeft);
                },
              ),
            ).animate().slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}