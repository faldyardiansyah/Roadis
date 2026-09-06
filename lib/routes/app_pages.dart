import 'package:get/get.dart';
import 'app_routes.dart';
import '../splash/onboarding_screen.dart';
import '../splash/splash_screen_1.dart';
import '../auth/screens/login_screen.dart';


class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash1, page: () => const SplashScreen1()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
  ];
}
