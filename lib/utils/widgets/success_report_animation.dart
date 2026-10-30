
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SuccessReportAnimation extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const SuccessReportAnimation({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<SuccessReportAnimation> createState() =>
      _SuccessReportAnimationState();
}

class _SuccessReportAnimationState
    extends State<SuccessReportAnimation> {
  bool _playedHaptic = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/lotties/success_report.json',
          width: 220,
          height: 220,
          repeat: true,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            if (!_playedHaptic) {
              _playedHaptic = true;
              HapticFeedback.lightImpact();
            }
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Laporan Berhasil Dikirim!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ).animate().fadeIn(
              duration: 450.ms,
              delay: 250.ms,
            ).slideY(
              begin: 0.2,
              end: 0,
              duration: 450.ms,
            ),
        const SizedBox(height: 10),
        const Text(
          'Terima kasih sudah membantu melaporkan '
          'kerusakan jalan. Laporan kamu akan ditinjau '
          'oleh petugas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF64748B),
          ),
        ).animate().fadeIn(
              duration: 450.ms,
              delay: 450.ms,
            ),
      ],
    );
  }
}