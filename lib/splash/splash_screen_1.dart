import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import 'splash_screen_2.dart';

import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';

class SplashScreen1 extends StatelessWidget {
  const SplashScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BatikPattern(
              height: size.height * 0.45,
              color: AppColors.primaryColor, 
              opacity: 0.09,          
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        '01',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        ' / 02',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black38,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        child: Text(
                          'Lewati',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ilustrasi
                Expanded(
                  child: Center(
                    child: Lottie.asset(
                      'assets/lotties/splash1.json',
                      width: size.width * 0.7,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Teks
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foto & laporkan\njalan rusak',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Ambil foto kerusakan jalan dan biarkan kecerdasan buatan menganalisis jenis serta tingkat kerusakannya.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 500.ms)
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Row(
                    children: [
                      _bar(active: true),
                      const SizedBox(width: 6),
                      _bar(active: false),
                      const Spacer(),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(
                              () => const SplashScreen2(),
                              transition: Transition.rightToLeft,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lanjut',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar({required bool active}) {
    return AnimatedContainer(
      duration: 250.ms,
      width: active ? 28 : 10,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryColor : Colors.black12,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
