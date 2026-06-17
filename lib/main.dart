import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'configs/theme.dart';
import 'configs/translations.dart';
import 'controllers/localization_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/game_controller.dart';
import 'controllers/connectivity_controller.dart';
import 'views/splash_view.dart';
import 'views/no_internet_view.dart';
import 'views/server_down_view.dart';
import 'views/maintenance_view.dart';
import 'views/update_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inject core controllers early
  Get.put(LocalizationController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(GameController(), permanent: true);
  Get.put(ConnectivityController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();
    final connectivityController = Get.find<ConnectivityController>();

    return Obx(() {
      final currentLanguage = localizationController.currentLanguage.value;

      return GetMaterialApp(
        title: 'Norbiz Lotto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        translations: AppTranslations(),
        locale: Locale(currentLanguage),
        fallbackLocale: const Locale('en', 'US'),
        home: const SplashView(),
        builder: (context, child) {
          return Obx(() {
            if (connectivityController.isUpdateRequired.value) {
              return const UpdateView();
            }
            if (connectivityController.isMaintenance.value) {
              return const MaintenanceView();
            }
            if (!connectivityController.isConnected.value) {
              return const NoInternetView();
            }
            if (connectivityController.isServerDown.value) {
              return const ServerDownView();
            }
            return child ?? const SizedBox();
          });
        },
      );
    });
  }
}
