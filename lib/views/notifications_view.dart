import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../configs/theme.dart';
import '../controllers/localization_controller.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();

    final customHeaderRow = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
          Text(
            'Notifications'.tr,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 38), // Spacer of same width to center the title
        ],
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFEFF3FD),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  customHeaderRow,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: IntrinsicHeight(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    Image.asset(
                                      'lib/assets/images/No Notification.png',
                                      width: 280,
                                      height: 280,
                                      fit: BoxFit.contain,
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () => Get.back(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFE9900),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'back_home'.tr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
