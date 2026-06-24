import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connectivity_controller.dart';

class ServerDownView extends StatelessWidget {
  const ServerDownView({Key? key}) : super(key: key);

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
                        // Server Down Image
                        Center(
                          child: Image.asset(
                            'lib/assets/images/Aerver Down.png',
                            width: 260,
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          'Server Down'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        // Got It Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // Try to re-check the server connection
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
                              'Got It'.tr,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
