import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../controllers/connectivity_controller.dart';

class UpdateView extends StatelessWidget {
  const UpdateView({Key? key}) : super(key: key);

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
                        // Brand Logo Image
                        Center(
                          child: Image.asset(
                            'lib/assets/images/Logo.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Title
                        Text(
                          'Needs An Update'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          'A new version of Norbiz Paryaj is available with improved performance, security, and new features. Please update the app to continue.'.tr,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              final String packageName = "com.example.norbiz_loto";
                              final Uri url = Platform.isAndroid
                                  ? Uri.parse("https://play.google.com/store/apps/details?id=" + packageName)
                                  : Uri.parse("https://apps.apple.app/app/id1234567895");
                              try {
                                bool launched = await launcher.launchUrl(url, mode: launcher.LaunchMode.externalApplication);
                                if (!launched) {
                                  await launcher.launchUrl(url);
                                }
                              } catch (e) {
                                debugPrint('Error launching store url: $e');
                                try {
                                  await launcher.launchUrl(url);
                                } catch (_) {}
                              }
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
                              'Update'.tr,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Google Play Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(20, 20),
                              painter: GooglePlayLogoPainter(),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Google Play',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

class GooglePlayLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Google Play colors
    final bluePaint = Paint()..color = const Color(0xFF00C6FF)..style = PaintingStyle.fill;
    final greenPaint = Paint()..color = const Color(0xFF00E676)..style = PaintingStyle.fill;
    final redPaint = Paint()..color = const Color(0xFFFF3A44)..style = PaintingStyle.fill;
    final yellowPaint = Paint()..color = const Color(0xFFFFC107)..style = PaintingStyle.fill;

    // Define vertices for perfect alignment:
    final p1x = 0.0;
    final p1y = h * 0.05;
    
    final p2x = 0.0;
    final p2y = h * 0.95;
    
    final p3x = w;
    final p3y = h * 0.5;

    // Center intersection point
    final cx = w * 0.42;
    final cy = h * 0.5;

    // Boundary division points on top and bottom edges
    final tx = w * 0.72;
    final ty = h * 0.374; // Aligned with the top edge line equation
    
    final bx = w * 0.72;
    final by = h * 0.626; // Aligned with the bottom edge line equation

    // 1. Draw Blue polygon (left)
    final bluePath = Path()
      ..moveTo(p1x, p1y)
      ..lineTo(p2x, p2y)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // 2. Draw Green polygon (top)
    final greenPath = Path()
      ..moveTo(p1x, p1y)
      ..lineTo(tx, ty)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // 3. Draw Red polygon (bottom)
    final redPath = Path()
      ..moveTo(p2x, p2y)
      ..lineTo(bx, by)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // 4. Draw Yellow polygon (right tip)
    final yellowPath = Path()
      ..moveTo(cx, cy)
      ..lineTo(tx, ty)
      ..lineTo(p3x, p3y)
      ..lineTo(bx, by)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
