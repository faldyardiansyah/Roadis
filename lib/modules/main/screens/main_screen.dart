import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/modules/camera/screens/report_camera_screen.dart';
import 'package:roadis/modules/history/screens/history_screen.dart';
import 'package:roadis/modules/profile/screens/profile_screen.dart';
import 'package:roadis/utils/app_colors.dart';

import '../../home/screens/home_screen.dart';
import '../../maps/screens/maps_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    ReportCameraScreen(
      onBack: () {
        setState(() {
          _currentIndex = 0;
        });
      },
    ),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _select(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isReportPage = _currentIndex == 2;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _screens[_currentIndex],

      // Tombol tengah melayang (Hero Camera Button)
      floatingActionButton: isReportPage
          ? null
          : Container(
              width: 62,
              height: 62,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppColors.skyBlue,
                    AppColors.primaryColor,
                    AppColors.deepNavy,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _select(2),
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 27,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar Modern & Elegan
      bottomNavigationBar: isReportPage
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 68,
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Beranda',
                        selected: _currentIndex == 0,
                        onTap: () => _select(0),
                      ),
                      _NavItem(
                        icon: Icons.map_outlined,
                        activeIcon: Icons.map_rounded,
                        label: 'Peta',
                        selected: _currentIndex == 1,
                        onTap: () => _select(1),
                      ),

                      // Area tengah tombol Lapor
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _select(2),
                        child: SizedBox(
                          width: 68,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lapor',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: _currentIndex == 2
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: _currentIndex == 2
                                      ? AppColors.primaryColor
                                      : const Color(0xFF64748B),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 7),
                            ],
                          ),
                        ),
                      ),

                      _NavItem(
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long_rounded,
                        label: 'Riwayat',
                        selected: _currentIndex == 3,
                        onTap: () => _select(3),
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profil',
                        selected: _currentIndex == 4,
                        onTap: () => _select(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryColor.withOpacity(0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selected ? activeIcon : icon,
                  size: 23,
                  color: selected
                      ? AppColors.primaryColor
                      : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? AppColors.primaryColor
                      : const Color(0xFF64748B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
