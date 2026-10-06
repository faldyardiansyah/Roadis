import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import 'auth/controllers/auth_controller.dart';
import 'auth/services/session_storage.dart';
import 'utils/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(AuthController(), permanent: true);
  await LocationService.checkAndRequestLocation();

  final token = SessionStorage.getToken();

  runApp(
    MyApp(
      initialRoute:
          token != null && token.isNotEmpty
              ? AppRoutes.main
              : AppRoutes.onboarding,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

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