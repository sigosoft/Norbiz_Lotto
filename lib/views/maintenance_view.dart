import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connectivity_controller.dart';

class MaintenanceView extends StatelessWidget {
  const MaintenanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityController = Get.find<ConnectivityController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Back Arrow Button
                        GestureDetector(
                          onTap: () {
                            connectivityController.isMaintenance.value = false;
                            Get.back();
                          },
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xFF0F172A),
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        // Maintenance Image
                        Center(
                          child: Image.asset(
                            'lib/assets/images/Maintanence.png',
                            width: 280,
                            height: 280,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Center(
                          child: Text(
                            "We'll Be Back Soon".tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF0F172A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Center(
                          child: Text(
                            "sorry, we're down for maintenance we'll be back up shortly.".tr,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
