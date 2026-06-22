import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/localization_controller.dart';
import '../../controllers/auth_controller.dart';
import '../dialogs/bet_success_view.dart';

class CartView extends StatelessWidget {
  const CartView({Key? key}) : super(key: key);

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

  String getDrawTime(String dateString) {
    if (dateString.contains('9:45')) {
      return '9:45 PM (Evening)';
    }
    return '2:00 PM (Afternoon)';
  }

  Widget buildSelectionBadges(String gameName, String numbers) {
    final isMaryaj = gameName.toLowerCase().contains('maryaj') || gameName.toLowerCase().contains('marriage');
    if (isMaryaj && numbers.length >= 4) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircularBadge(numbers.substring(0, 2)),
          const SizedBox(width: 8.0),
          _buildCircularBadge(numbers.substring(2, 4)),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        numbers.length,
        (idx) => Padding(
          padding: EdgeInsets.only(left: idx == 0 ? 0.0 : 8.0),
          child: _buildCircularBadge(numbers[idx]),
        ),
      ),
    );
  }

  Widget _buildCircularBadge(String text) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF002C8B),
        shape: BoxShape.circle,
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
    final cartController = Get.find<CartController>();
    final localizationController = Get.find<LocalizationController>();
    final authController = Get.find<AuthController>();

    if (cartController.cartTickets.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (cartController.cartTickets.isEmpty) {
          cartController.addTicket('Borlette FL', '99', 10.0);
        }
      });
    }

    final customHeaderRow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF002C8B),
                size: 16,
              ),
            ),
          ),
          Text(
            'Your Cart',
            style: const TextStyle(
              color: Color(0xFF002C8B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );

    final emptyWidget = Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
                        'lib/assets/images/Cart Empty.png',
                        width: 280,
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          minimumSize: const Size(180, 48),
                          elevation: 0,
                        ),
                        child: Text('back_home'.tr),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    final walletBalanceCard = Obx(() {
      final balance = authController.userWalletBalance.value;
      final totalAmount = cartController.total;
      final isSufficient = balance >= totalAmount;

      return CustomPaint(
        painter: DashedRectPainter(
          color: const Color(0xFFFE9900),
          strokeWidth: 1.5,
          gap: 5.0,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDFB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Wallet Balance",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "\$${balance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSufficient
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSufficient
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cancel_outlined,
                              color: isSufficient
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isSufficient
                                  ? "Sufficient Balance"
                                  : "Insufficient",
                              style: TextStyle(
                                color: isSufficient
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFFFE9900),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Top Up Wallet",
                      style: TextStyle(
                        color: Color(0xFFFE9900),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });

    final summaryCard = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            "Total Tickets",
            "${cartController.cartTickets.length}",
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            "Subtotal",
            "\$${cartController.subtotal.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            "Service Fee",
            "\$${cartController.serviceFee.toStringAsFixed(2)}",
          ),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 28),
          _buildSummaryRow(
            "Total Amount",
            "\$${cartController.total.toStringAsFixed(2)}",
            isBold: true,
          ),
        ],
      ),
    );

    Widget buildCartList() {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Obx(
              () => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartController.cartTickets.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ticket = cartController.cartTickets[index];
                  return Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
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
                                    ticket.gameName,
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
                            IconButton(
                              icon: Image.asset(
                                "lib/assets/images/Delete.png",
                                width: 18,
                                height: 18,
                              ),
                              onPressed: () =>
                                  cartController.removeTicket(index),
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
                                  "\$${calculatePotentialWin(ticket.gameName, ticket.betAmount).toStringAsFixed(2)}",
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
                                  getDrawTime(ticket.date),
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
                            buildSelectionBadges(
                              ticket.gameName,
                              ticket.numbers,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Bet Amount",
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "\$${ticket.betAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Color(0xFF002C8B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            walletBalanceCard,
            const SizedBox(height: 16),
            summaryCard,
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (cartController.cartTickets.isEmpty) return;
                final ticket = cartController.cartTickets.first;
                final amt = cartController.total;

                if (cartController.checkout()) {
                  Get.to(
                    () => BetSuccessView(
                      ticketId: ticket.id,
                      gameName: ticket.gameName,
                      betNumber: ticket.numbers,
                      amount: amt,
                    ),
                  );
                  cartController.clearCart();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Bet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  customHeaderRow,
                  Expanded(
                    child: Obx(
                      () => cartController.cartTickets.isEmpty
                          ? emptyWidget
                          : buildCartList(),
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 14 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 16 : 13,
          ),
        ),
      ],
    );
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
