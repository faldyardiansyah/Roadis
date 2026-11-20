import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';
import 'package:roadis/modules/home/widgets/home_header.dart';
import 'package:roadis/modules/home/widgets/recent_reports.dart';
import 'package:roadis/modules/home/widgets/report_map.dart';
import 'package:roadis/modules/home/widgets/report_stats.dart';
import 'package:roadis/modules/home/widgets/service_banner.dart';
import 'package:roadis/modules/home/widgets/tips_card.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeC = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Batik tipis di latar atas, memudar ke bawah
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BatikPattern(
              height: 300,
              color: AppColors.primaryColor,
              opacity: 0.20,
              scale: 2.6,
            ),
          ),
          // Wash warna lembut supaya mirip referensi (pastel)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.10),
                      const Color(0xFFF8FAFC).withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: homeC.refreshAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 18),
                    const ServiceBanner(),
                    const SizedBox(height: 18),
                    const ReportStats(),
                    const SizedBox(height: 22),
                    const TipsCard(),
                    const SizedBox(height: 22),
                    const ReportMap(),
                    const SizedBox(height: 22),
                    const RecentReports(),
                  ]
                      .animate(interval: 90.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}