import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadis/modules/camera/screens/report_camera_screen.dart';
import 'package:roadis/modules/history/screens/history_screen.dart';
import 'package:roadis/modules/profile/screens/profile_screen.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

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
    HapticFeedback.selectionClick();
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

      // Tombol tengah (kamera)
      floatingActionButton: isReportPage
          ? null
          : SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                backgroundColor: AppColors.primaryColor,
                elevation: 4,
                highlightElevation: 2,
                shape: const CircleBorder(),
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () => _select(2),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom navigation tidak tampil saat halaman kamera aktif.
      bottomNavigationBar: isReportPage
          ? null
          : BottomAppBar(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.25),
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              padding: EdgeInsets.zero,
              height: 70,
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    selected: _currentIndex == 0,
                    onTap: () => _select(0),
                  ),
                  _NavItem(
                    icon: Icons.map_outlined,
                    activeIcon: Icons.map_rounded,
                    label: 'Maps',
                    selected: _currentIndex == 1,
                    onTap: () => _select(1),
                  ),
                  const SizedBox(width: 72), // ruang untuk tombol kamera
                  _NavItem(
                    icon: Icons.history_rounded,
                    activeIcon: Icons.history_rounded,
                    label: 'History',
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
    final color = selected ? AppColors.primaryColor : Colors.grey.shade700;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          // Container hanya terlihat saat menu aktif
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 60,
            height: 52,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryColor.withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? activeIcon : icon, size: 22, color: color),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
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
