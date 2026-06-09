import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'configs/theme.dart';
import 'configs/translations.dart';
import 'controllers/localization_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/cart_controller.dart';
import 'views/splash_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inject core controllers early
  Get.put(LocalizationController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(CartController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();

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
      );
    });
  }
}
