import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connectivity_controller.dart';

class NoInternetView extends StatelessWidget {
  const NoInternetView({Key? key}) : super(key: key);

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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // No Internet Image
                        Center(
                          child: Image.asset(
                            'lib/assets/images/No Internet.png',
                            width: 260,
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          'No Internet Connection'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        Text(
                          'please check your internet connection and try again.'.tr,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        // Try Again Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              connectivityController.checkConnection();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFE9900),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Try Again'.tr,
                              style: TextStyle(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
