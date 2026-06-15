import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../models/ticket_model.dart';
import '../../controllers/bet_history_controller.dart';
import '../../controllers/localization_controller.dart';
import '../../controllers/home_controller.dart';

class BetHistoryView extends StatelessWidget {
  const BetHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final historyController = Get.put(BetHistoryController());
    final localizationController = Get.find<LocalizationController>();

    final emptyWidget = Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF3FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Colors.grey,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_bet_history'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppTheme.primaryDarkBlue,
              ),
            ),
          ],
        ),
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.find<HomeController>().changeNavIndex(0);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: AppTheme.primaryDarkBlue,
                            ),
                          ),
                        ),
                        Text(
                          'bet_history'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ), // Spacer to balance back button
                      ],
                    ),
                  ),

                  // Search input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: historyController.updateSearch,
                        decoration: const InputDecoration(
                          hintText: 'Search by lottery or draw',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  // Capsule Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: ['All', 'Pending', 'Won', 'Loss'].map((
                          filter,
                        ) {
                          return Obx(() {
                            final isSelected =
                                historyController.activeFilter.value == filter;
                            return GestureDetector(
                              onTap: () =>
                                  historyController.changeFilter(filter),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryOrange
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryOrange
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  filter == 'Loss'
                                      ? 'loss'.tr
                                      : filter == 'Won'
                                      ? 'won'.tr
                                      : filter == 'Pending'
                                      ? 'pending'.tr
                                      : 'all_bets'.tr,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryDarkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // History list results
                  Expanded(
                    child: Obx(() {
                      final list = historyController.filteredTickets;
                      if (list.isEmpty) return emptyWidget;

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: list.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final ticket = list[index];

                          // Determine status colors/labels
                          Color statusColor = const Color(0xFFFE9900);
                          String statusLabel = 'PENDING';
                          if (ticket.status == TicketStatus.won) {
                            statusColor = const Color(0xFF10B981);
                            statusLabel = 'WIN';
                          } else if (ticket.status == TicketStatus.lost) {
                            statusColor = const Color(0xFFEF4444);
                            statusLabel = 'LOSS';
                          }

                          // Split ticket numbers by comma or space
                          final numberList = ticket.numbers
                              .split(RegExp(r'[,\s]+'))
                              .where((s) => s.isNotEmpty)
                              .toList();

                          return CustomPaint(
                            painter: TicketPainter(
                              borderColor: const Color(0xFFE2E8F0),
                              shadowColor: Colors.black,
                              cutoutY: 80.0,
                              dottedLineY: 98.0,
                            ),
                            child: SizedBox(
                              height: 140,
                              child: Stack(
                                children: [
                                  // Top section content
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 95,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        14,
                                        16,
                                        8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              text: 'Ticket ID: ',
                                              style: const TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: ticket.id,
                                                  style: const TextStyle(
                                                    color: Color(0xFFFE9900),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                ticket.gameName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppTheme.primaryDarkBlue,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '\$${ticket.betAmount.toInt()}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppTheme.primaryDarkBlue,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: numberList.map((num) {
                                              return Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                margin: const EdgeInsets.only(
                                                  right: 6,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF002C8B),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  num,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Status tag at top-right corner
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 80,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Bottom section content
                                  Positioned(
                                    top: 95,
                                    left: 0,
                                    right: 0,
                                    height: 45,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.history,
                                                size: 16,
                                                color: Color(0xFF707E94),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                ticket.date,
                                                style: const TextStyle(
                                                  color: Color(0xFF707E94),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (ticket.status ==
                                                  TicketStatus.won &&
                                              ticket.winAmount != null)
                                            Text(
                                              '+\$${ticket.winAmount!.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Color(0xFF10B981),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            )
                                          else if (ticket.status ==
                                              TicketStatus.lost)
                                            Text(
                                              '-\$${ticket.betAmount.toInt()}',
                                              style: const TextStyle(
                                                color: Color(0xFFEF4444),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
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

class TicketPainter extends CustomPainter {
  final Color borderColor;
  final Color shadowColor;
  final double cutoutY;
  final double dottedLineY;

  TicketPainter({
    required this.borderColor,
    required this.shadowColor,
    required this.cutoutY,
    required this.dottedLineY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 14.0;
    final cornerRadius = 16.0;

    final path = Path();

    // Start at top-left corner after rounding
    path.moveTo(cornerRadius, 0.0);

    // Top side to top-right corner
    path.lineTo(size.width - cornerRadius, 0.0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Right side down to cutout
    path.lineTo(size.width, cutoutY - radius);
    path.arcToPoint(
      Offset(size.width, cutoutY + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Right side down to bottom-right corner
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Bottom side to bottom-left corner
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(
      Offset(0.0, size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Left side up to cutout
    path.lineTo(0.0, cutoutY + radius);
    path.arcToPoint(
      Offset(0.0, cutoutY - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Left side up to top-left corner
    path.lineTo(0.0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0.0),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    path.close();

    // Draw Shadow
    final shadowPaint = Paint()
      ..color = shadowColor.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);

    // Draw Fill
    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFill);

    // Draw Border
    final paintBorder = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, paintBorder);

    // Draw Dashed Line divider
    final paintDashed = Paint()
      ..color = borderColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dashWidth = 4.0;
    final dashSpace = 4.0;
    double startX = 0.0;
    final endX = size.width;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, dottedLineY),
        Offset(startX + dashWidth, dottedLineY),
        paintDashed,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
