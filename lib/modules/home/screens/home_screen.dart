import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';
import 'package:roadis/modules/home/widgets/home_header.dart';
import 'package:roadis/modules/home/widgets/quick_actions.dart';
import 'package:roadis/modules/home/widgets/recent_reports.dart';
import 'package:roadis/modules/home/widgets/report_stats.dart';
import 'package:roadis/modules/home/widgets/tips_card.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeC = Get.put(HomeController());
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: RefreshIndicator(
          color: AppColors.primaryColor,
          edgeOffset: topInset + 8,
          onRefresh: homeC.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Stack(
              children: [
                // Latar header gradasi + batik + watermark burung khas Indramayu (ikut ter-scroll)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topInset + 250,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor,
                            AppColors.midnightBlue,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: BatikPattern(
                              color: Colors.white,
                              opacity: 0.12,
                              scale: 2.4,
                              fadeOut: true,
                            ),
                          ),
                          // Watermark Burung Khas Indramayu di Pojok Kanan Atas
                          Positioned(
                            top: -8,
                            right: -15,
                            width: 250,
                            height: 230,
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0.28,
                                child: Image.asset(
                                  'assets/images/burung_batik.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.topRight,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -50,
                            top: -60,
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, topInset + 14, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        [
                              const HomeHeader(),
                              const SizedBox(height: 18),
                              const ReportStats(),
                              const SizedBox(height: 16),
                              const QuickActions(),
                              const SizedBox(height: 24),
                              const TipsCard(),
                              const SizedBox(height: 24),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
