import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _Action(
            icon: Icons.photo_camera_rounded,
            label: 'Lapor',
            filled: true,
            onTap: () => Get.toNamed(AppRoutes.reportCamera),
          ),
          _Action(
            icon: Icons.map_rounded,
            label: 'Peta',
            onTap: () => Get.toNamed(AppRoutes.maps),
          ),
          _Action(
            icon: Icons.notifications_rounded,
            label: 'Notifikasi',
            onTap: () => Get.toNamed(AppRoutes.notifikasi),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: filled
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withOpacity(0.09),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 25,
                color: filled ? Colors.white : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: TextColors.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}