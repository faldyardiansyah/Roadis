import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:roadis/utils/app_colors.dart';

void showLoadingOverlay({String? message}) {
  // Hindari dialog ganda kalau dipanggil dua kali.
  if (Get.isDialogOpen ?? false) return;

  Get.dialog(
    PopScope(
      canPop: false, 
      child: _LoadingOverlay(message: message),
    ),
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    useSafeArea: false,
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Menutup loading.
void hideLoadingOverlay() {
  if (Get.isDialogOpen ?? false) Get.back();
}

class _LoadingOverlay extends StatelessWidget {
  final String? message;

  const _LoadingOverlay({this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, t, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10 * t, sigmaY: 10 * t),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.25 * t),
              child: child,
            ),
          );
        },
        child: Center(
          child:
              Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: message == null ? 24 : 26,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.18),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lotties/loading.json',
                          width: 96,
                          height: 96,
                          repeat: true,
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            message!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 250.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 350.ms,
                    curve: Curves.easeOutBack,
                  ),
        ),
      ),
    );
  }
}
