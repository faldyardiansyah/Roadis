import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primaryColor = Color(0xFF0077B6);
  static const Color primaryDarkColor = Color(0xFF005F8D);
  static const Color primaryLightColor = Color(0xFF48CAE4);

  // Background
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color white1Color = Color(0xFFF8FAFC);
  static const Color whitetr = Color(0xFFE2E8F0);
  static const Color backgroundColor = Color(0xFFF5F9FC);

  // Text
  static const Color blackColor = Color(0xFF000000);
  static const Color darkTextColor = Color(0xFF1E293B);
  static const Color greyColor = Color(0xFF6B7280);
  static const Color lightGreyColor = Color(0xFF94A3B8);
  static const Color secondaryTextColor = Color(0xFF6C757D);

  // Status
  static const Color redColor = Color(0xFFDC2626);
  static const Color greenColor = Color(0xFF22C55E);
  static const Color yellowColor = Color(0xFFF59E0B);
  static const Color orangeColor = Color(0xFFF97316);

  // Border & divider
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Transparent / soft colors
  static final Color primaryColorLight =
      primaryColor.withOpacity(0.2);

  static final Color secondaryColor =
      primaryLightColor.withOpacity(0.2);

  static final Color greenColorLight =
      greenColor.withOpacity(0.12);

  static final Color redColorLight =
      redColor.withOpacity(0.12);

  static final Color yellowColorLight =
      yellowColor.withOpacity(0.12);
}

class TextColors {
  static const Color primaryTextColor = Color(0xFF000000);
  static const Color secondaryTextColor = Color(0xFF6C757D);
  static const Color whiteTextColor = Color(0xFFFFFFFF);

  static const Color darkTextColor = Color(0xFF1E293B);
  static const Color greyTextColor = Color(0xFF6B7280);
  static const Color lightTextColor = Color(0xFF94A3B8);
}