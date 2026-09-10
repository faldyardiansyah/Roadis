import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roadis/modules/home/widgets/home_header.dart';
import 'package:roadis/modules/home/widgets/recent_reports.dart';
import 'package:roadis/modules/home/widgets/report_map.dart';
import 'package:roadis/modules/home/widgets/report_stats.dart';
import 'package:roadis/modules/home/widgets/service_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(
                    begin: -0.15,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 20),

              ServiceBanner()
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 100.ms)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: 700.ms,
                    delay: 100.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 8),

              ReportStats()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 8),

              ReportMap()
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 300.ms)
                  .scale(
                    begin: const Offset(0.96, 0.96),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    delay: 300.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 8),

              RecentReports()
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 400.ms)
                  .slideY(
                    begin: 0.12,
                    end: 0,
                    duration: 700.ms,
                    delay: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
