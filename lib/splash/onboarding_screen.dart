import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import './controllers/onboarding_controller.dart';
import 'package:roadis/utils/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Center(
                child:
                    Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.alt_route_rounded,
                            size: 72,
                            color: Colors.white,
                          ),
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.05, 1.05),
                          duration: 2000.ms,
                          curve: Curves.easeInOutSine,
                        )
                        .fadeIn(duration: 800.ms, curve: Curves.easeOut),
              ),

              const SizedBox(height: 32),
              Text(
                    'Roadis',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: TextColors.whiteTextColor,
                      letterSpacing: 0.8,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 800.ms)
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOutQuint,
                  ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                    'Sistem Inspeksi & Pelaporan Jalan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: TextColors.whiteTextColor.withOpacity(0.75),
                      letterSpacing: 0.2,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOutQuint,
                  ),

              const Spacer(),

              // Bagian Bawah (Indikator & Controller Text)
              Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () =>
                            Text(
                                  controller.pesanSaatIni.value,
                                  key: ValueKey<String>(
                                    controller.pesanSaatIni.value,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.whiteColor,
                                    letterSpacing: 0.1,
                                  ),
                                )
                                .animate(
                                  key: ValueKey(controller.pesanSaatIni.value),
                                )
                                .fadeIn(duration: 400.ms)
                                .scale(
                                  begin: const Offset(0.95, 0.95),
                                  end: const Offset(1, 1),
                                ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 800.ms)
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOutQuint,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
