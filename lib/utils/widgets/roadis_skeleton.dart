import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RoadisSkeleton extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const RoadisSkeleton({super.key, required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      enableSwitchAnimation: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFE6EAF2),
        highlightColor: Color(0xFFF7F9FC),
        duration: Duration(milliseconds: 1400),
      ),
      // Kartu tetap putih, hanya isinya yang jadi bone.
      containersColor: Colors.white,
      child: child,
    );
  }
}
