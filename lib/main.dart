import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

import 'auth/controllers/auth_controller.dart';
import 'utils/location_service.dart';

import 'package:roadis/modules/notification/services/local_notification_service.dart';
import 'package:roadis/modules/notification/services/notification_polling_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await GetStorage.init();
  await LocalNotificationService.initialize();

  NotificationPollingService.instance.start();

  Get.put(AuthController(), permanent: true);

  await LocationService.checkAndRequestLocation();

  // Selalu jalankan splash screen (AppRoutes.onboarding) terlebih dahulu
  // OnboardingController akan mengarahkan:
  // - Jika sudah login: Splash Screen -> AppRoutes.main (melewati onboarding walkthrough)
  // - Jika belum login: Splash Screen -> AppRoutes.splash1 (onboarding walkthrough) -> Login
  runApp(
    const MyApp(
      initialRoute: AppRoutes.onboarding,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Roadis',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
