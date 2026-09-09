import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:roadis/utils/app_colors.dart';

void showLoadingOverlay() {
  Get.dialog(
    Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Lottie.asset(
          'assets/lotties/loading.json',
          width: 120,
          height: 120,
          repeat: true,
        ),
      )
    ),
    barrierDismissible: false,
  );
} 