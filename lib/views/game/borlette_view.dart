import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../models/game_model.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/localization_controller.dart';
import '../dialogs/bet_success_view.dart';
import '../../configs/toast.dart';

class BorletteView extends StatelessWidget {
  final GameModel game;

  const BorletteView({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameController = Get.put(GameController());
    gameController.setActiveGame(game);
    
    final cartController = Get.find<CartController>();
    final localizationController = Get.find<LocalizationController>();

    final headerCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryDarkBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agent Bon Chans',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'FL Evening • Pick ${game.category}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(10)),
            child: Text(
              game.payout.replaceAll('Payout: ', ''),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );

    // Number Selection Box displaying selected digits
    final selectionBox = Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'pick_number'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.primaryOrange, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'warning_sales_limit'.tr,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Displaying boxes for active characters
          Obx(() {
            String selected = gameController.selectedNumbers.value;
            int totalLen = game.category == '2D' ? 2 : game.category == '3D' ? 3 : 4;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalLen, (index) {
                String val = 'X';
                if (index < selected.length) {
                  val = selected[index];
                }
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreyBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: val != 'X' ? AppTheme.primaryOrange : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    val,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: val != 'X' ? AppTheme.primaryOrange : Colors.grey,
                    ),
                  ),
                );
              }),
            );
          }),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: gameController.clearSelection,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  child: Text('clear_selection'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: gameController.performQuickPick,
                  child: Text('quick_pick'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Keypad layout
    final keypadWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(9, (index) {
              String key = '${index + 1}';
              return _buildKeyButton(key, () => gameController.pressKey(key));
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Placeholder/spacer to center the 0 and Backspace
              Expanded(child: const SizedBox()),
              Expanded(child: _buildKeyButton('0', () => gameController.pressKey('0'))),
              Expanded(
                child: InkWell(
                  onTap: gameController.pressBackspace,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Icon(Icons.backspace_outlined, color: AppTheme.primaryDarkBlue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Bottom selection details input panel
    final betInputPanel = Obx(() {
      String selected = gameController.selectedNumbers.value;
      int requiredLen = game.category == '2D' ? 2 : game.category == '3D' ? 3 : 4;
      if (selected.length < requiredLen) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'your_selection'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: const BoxDecoration(color: AppTheme.primaryDarkBlue, shape: BoxShape.circle),
                  child: Text(
                    selected,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'enter_amount'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGrey),
            ),
            const SizedBox(height: 6),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (val) => gameController.enteredAmount.value = val,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
              decoration: InputDecoration(
                hintText: '\$0.00',
                suffixText: 'USD',
                helperText: 'min_max'.tr,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      double amount = double.tryParse(gameController.enteredAmount.value) ?? 0.0;
                      if (gameController.validateBet(amount)) {
                        cartController.addTicket(game.name, selected, amount);
                        gameController.clearSelection();
                        showToast('Ticket added to your cart successfully.'.tr, title: 'Added to Cart');
                      }
                    },
                    child: Text('add_to_cart'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      double amount = double.tryParse(gameController.enteredAmount.value) ?? 0.0;
                      if (gameController.validateBet(amount)) {
                        cartController.clearCart();
                        cartController.addTicket(game.name, selected, amount);
                        
                        // Execute checkout
                        if (cartController.checkout()) {
                          Get.to(() => BetSuccessView(
                            ticketId: cartController.cartTickets.first.id,
                            gameName: game.name,
                            betNumber: selected,
                            amount: amount,
                          ));
                          cartController.clearCart();
                          gameController.clearSelection();
                        }
                      }
                    },
                    child: Text('buy_ticket'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });

    return Obx(() {
      final textDirection = localizationController.textDirection;
      final orientation = MediaQuery.of(context).orientation;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryDarkBlue),
              onPressed: () => Get.back(),
            ),
            title: Text(
              '${game.name} ${game.category}',
              style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: AppTheme.primaryDarkBlue),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text(game.name),
                      content: Text('Payout rate details:\n${game.payout}'),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: const Text('OK')),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: orientation == Orientation.portrait
                      ? Column(
                          children: [
                            headerCard,
                            const SizedBox(height: 16),
                            selectionBox,
                            const SizedBox(height: 16),
                            keypadWidget,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  headerCard,
                                  const SizedBox(height: 16),
                                  selectionBox,
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 5,
                              child: keypadWidget,
                            ),
                          ],
                        ),
                ),
              ),
              // Place Bet input Drawer panel at bottom
              betInputPanel,
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKeyButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.lightGreyBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDarkBlue,
          ),
        ),
      ),
    );
  }
}
