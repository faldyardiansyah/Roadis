import 'package:get/get.dart';
import 'package:roadis/modules/camera/screens/report_camera_screen.dart';
import 'package:roadis/modules/main/screens/main_screen.dart';

import 'app_routes.dart';
import '../splash/onboarding_screen.dart';
import '../splash/splash_screen_1.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/register_screen.dart';
import '../modules/maps/screens/maps_screen.dart';
import '../modules/notification/screens/notification_screen.dart';
import '../modules/profile/screens/bantuan_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash1,
      page: () => const SplashScreen1(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
    ),
    GetPage(
      name: AppRoutes.maps,
      page: () => const MapScreen(),
    ),
    GetPage(
      name: AppRoutes.notifikasi,
      page: () => const NotificationScreen(),
    ),

    // Punya kamu
    GetPage(
      name: AppRoutes.faq,
      page: () => const BantuanScreen(),
    ),

    // Tambahan dari teman
    GetPage(
      name: AppRoutes.reportCamera,
      page: () => const ReportCameraScreen(),
    ),
  ];
}