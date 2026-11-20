import 'package:flutter/material.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RoadisSkeleton extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const RoadisSkeleton({super.key, required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: AppColors.primaryColor.withOpacity(0.12),
        highlightColor: AppColors.primaryColor.withOpacity(0.03),
        duration: const Duration(milliseconds: 3000),
      ),
      containersColor: AppColors.primaryColor.withOpacity(0.08),
      child: child,
    );
  }
}