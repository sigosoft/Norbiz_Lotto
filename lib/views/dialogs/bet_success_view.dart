import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:norbiz_loto/controllers/home_controller.dart';
import '../../configs/theme.dart';
import '../../controllers/localization_controller.dart';
import '../navigation/main_navigation_view.dart';

class BetSuccessView extends StatelessWidget {
  final String ticketId;
  final String gameName;
  final String betNumber;
  final double
  amount; // represents the total amount paid (including service fee)

  const BetSuccessView({
    Key? key,
    required this.ticketId,
    required this.gameName,
    required this.betNumber,
    required this.amount,
  }) : super(key: key);

  double calculatePotentialWin(String gameName, double betAmount) {
    final name = gameName.toLowerCase();
    if (name.contains('borlette')) {
      return betAmount * 60;
    } else if (name.contains('3')) {
      return betAmount * 500;
    } else if (name.contains('4')) {
      return betAmount * 4500;
    } else if (name.contains('5')) {
      return betAmount * 50000;
    } else if (name.contains('maryaj') || name.contains('marriage')) {
      return betAmount * 50000;
    }
    return betAmount * 60;
  }

  String getDrawTime(String gameName) {
    if (gameName.toLowerCase().contains('evening')) {
      return '9:45 PM (Evening)';
    }
    return '2:00 PM (Afternoon)';
  }

  Widget _buildCircularBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: text.length > 2 ? 8.0 : 0.0),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF002C8B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();
    final double betAmount = amount >= 1.0 ? amount - 1.0 : amount;

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Stacked stars and successtick images
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/images/stars.png",
                        width: 300,
                        height: 190,
                        fit: BoxFit.contain,
                      ),
                      Image.asset(
                        "lib/assets/images/successtick.png",
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Bet Placed Successfully",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your luck is in the draw. Good luck!",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Ticket ID with dashed border
                  CustomPaint(
                    painter: DashedRectPainter(
                      color: const Color(0xFFCBD5E1),
                      strokeWidth: 1.5,
                      gap: 4.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Ticket ID",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticketId,
                            style: const TextStyle(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ticket Summary header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ticket_summary".tr.isEmpty
                          ? "Ticket Summary"
                          : "ticket_summary".tr,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Ticket Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  "lib/assets/images/cardimage.png",
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gameName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Agent Bon Chans",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildCircularBadge(betNumber),
                          ],
                        ),
                        const Divider(
                          color: Color(0xFFF1F5F9),
                          thickness: 1,
                          height: 28,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Potential Win",
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "\$${calculatePotentialWin(gameName, betAmount).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Color(0xFF002C8B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Draw Time",
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  getDrawTime(gameName),
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(
                          color: Color(0xFFF1F5F9),
                          thickness: 1,
                          height: 28,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount",
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "\$${amount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  ElevatedButton(
                    onPressed: () {
                      Get.offAll(() => const MainNavigationView());
                      Get.find<HomeController>().changeNavIndex(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(double.infinity, 40),
                      elevation: 0,
                    ),
                    child: const Text(
                      "View My Bet",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAll(() => const MainNavigationView());
                            Get.find<HomeController>().changeNavIndex(0);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFF2FD),
                            foregroundColor: const Color(0xFF002C8B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            minimumSize: const Size(0, 40),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Back to Home",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAll(() => const MainNavigationView());
                            Get.find<HomeController>().changeNavIndex(0);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF7ED),
                            foregroundColor: AppTheme.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            minimumSize: const Size(0, 40),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Play Again",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = const Color(0xFFFE9900),
    this.strokeWidth = 1.5,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;
    const double radius = 20.0;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, width, height),
          const Radius.circular(radius),
        ),
      );

    final Path dashedPath = Path();
    for (final PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      gap != oldDelegate.gap;
}
