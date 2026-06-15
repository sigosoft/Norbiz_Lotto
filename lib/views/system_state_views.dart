import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../configs/theme.dart';
import '../configs/toast.dart';
import '../controllers/localization_controller.dart';

class NoInternetView extends StatelessWidget {
  const NoInternetView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreyBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: AppTheme.primaryDarkBlue,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'no_internet'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppTheme.primaryDarkBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'no_internet_desc'.tr,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('try_again'.tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class ServerDownView extends StatelessWidget {
  const ServerDownView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreyBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.dns_outlined,
                      color: AppTheme.primaryOrange,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'server_down'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppTheme.primaryDarkBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'server_down_desc'.tr,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('got_it'.tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class AppUpdateRequiredView extends StatelessWidget {
  final bool isAndroid;

  const AppUpdateRequiredView({Key? key, this.isAndroid = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Small logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryDarkBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.casino_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'needs_update'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppTheme.primaryDarkBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'update_desc'.tr,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      showToast(
                        'Opening store download page...',
                        title: 'Redirecting',
                      );
                    },
                    icon: Icon(isAndroid ? Icons.play_arrow : Icons.apple),
                    label: Text(
                      isAndroid ? 'Google Play' : 'App Store',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
