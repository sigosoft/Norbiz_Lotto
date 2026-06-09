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
  final double amount;

  const BetSuccessView({
    Key? key,
    required this.ticketId,
    required this.gameName,
    required this.betNumber,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Success Icon Graphic
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'bet_placed'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppTheme.primaryDarkBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'bet_placed_desc'.tr,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Summary Card Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreyBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildRow('ticket_id'.tr, ticketId, isBold: true),
                        const Divider(height: 24),
                        _buildRow('game'.tr, gameName),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pick Number',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              height: 28,
                              width: 28,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryDarkBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                betNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildRow('draw_time'.tr, '2:00 PM (Afternoon)'),
                        const Divider(height: 24),
                        _buildRow(
                          'amount'.tr,
                          '\$${amount.toStringAsFixed(2)}',
                          valueColor: AppTheme.primaryOrange,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom buttons
                  ElevatedButton(
                    onPressed: () {
                      Get.offAll(() => const MainNavigationView());
                      // Direct user to Bet History tab
                      Get.find<HomeController>().changeNavIndex(2);
                    },
                    child: Text('view_my_bet'.tr),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        Get.offAll(() => const MainNavigationView()),
                    child: Text('play_again'.tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
            color: valueColor ?? AppTheme.primaryDarkBlue,
          ),
        ),
      ],
    );
  }
}
