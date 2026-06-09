import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/localization_controller.dart';
import '../dialogs/bet_success_view.dart';

class CartView extends StatelessWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final localizationController = Get.find<LocalizationController>();

    final emptyWidget = Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom drawing Shopping Cart Empty state
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: AppTheme.lightGreyBg, shape: BoxShape.circle),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.grey,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryDarkBlue),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('back_home'.tr),
            ),
          ],
        ),
      ),
    );

    Widget buildCartList() {
      return Column(
        children: [
          Expanded(
            child: Obx(() => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartController.cartTickets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ticket = cartController.cartTickets[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: AppTheme.primaryDarkBlue, shape: BoxShape.circle),
                            child: Text(
                              ticket.numbers,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket.gameName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ticket.date,
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${ticket.betAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => cartController.removeTicket(index),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
          
          // Checkout Calculations and Button card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => _buildSummaryRow('Subtotal', '\$${cartController.subtotal.toStringAsFixed(2)}')),
                const SizedBox(height: 8),
                Obx(() => _buildSummaryRow('Service Fee', '\$${cartController.serviceFee.toStringAsFixed(2)}')),
                const Divider(height: 24),
                Obx(() => _buildSummaryRow('Total', '\$${cartController.total.toStringAsFixed(2)}', isBold: true)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Cache details before checkout clear
                    final ticket = cartController.cartTickets.first;
                    final amt = cartController.total;
                    
                    if (cartController.checkout()) {
                      Get.to(() => BetSuccessView(
                        ticketId: ticket.id,
                        gameName: ticket.gameName,
                        betNumber: ticket.numbers,
                        amount: amt,
                      ));
                      cartController.clearCart();
                    }
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryDarkBlue),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'cart'.tr,
              style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          backgroundColor: AppTheme.lightGreyBg,
          body: Obx(() => cartController.cartTickets.isEmpty ? emptyWidget : buildCartList()),
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
            color: isBold ? AppTheme.primaryDarkBlue : Colors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppTheme.primaryOrange : AppTheme.primaryDarkBlue,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 17 : 13,
          ),
        ),
      ],
    );
  }
}
