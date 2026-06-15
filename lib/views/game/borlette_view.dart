import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../models/game_model.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/localization_controller.dart';
import '../dialogs/bet_success_view.dart';
import '../cart/cart_view.dart';

class BorletteView extends StatelessWidget {
  final GameModel game;

  const BorletteView({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameController = Get.put(GameController());
    gameController.setActiveGame(game);

    final cartController = Get.find<CartController>();
    final localizationController = Get.find<LocalizationController>();
    final amountController = TextEditingController();

    // Custom Header Row matching mockups
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
            '${game.name} ${game.category}',
            style: const TextStyle(
              color: Color(0xFF002C8B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(game.name),
                  content: Text('Payout rate details:\n${game.payout}'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF0D319C),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Image.asset(
                "lib/assets/images/Question.png",
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );

    // Redesigned Game Header Card matching the home page agent cards (including white radial light effects)
    final headerCard = Container(
      decoration: BoxDecoration(
        color: AppTheme.loginSheetBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Agent Header Band
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agent Bon Chans',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Text(
                  'Next Draw is 2:00 PM (Afternoon)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Gradient Body Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: game.category == '3D'
                  ? AppTheme.lotto3Gradient
                  : game.category == '4D'
                  ? AppTheme.lotto4Gradient
                  : game.category == '5D'
                  ? AppTheme.lotto5Gradient
                  : (game.category == '2 C' || game.category == '2 combo')
                  ? AppTheme.maryajGradient
                  : AppTheme.borletteGradient,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Column with Logo & Draw Details
                Row(
                  children: [
                    // Balls square graphic
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: game.category == '3D'
                            ? const Color(0xFF3A86FF)
                            : game.category == '4D'
                            ? const Color(0xFFFF4D4D)
                            : game.category == '5D'
                            ? const Color(0xFF2ECC71)
                            : (game.category == '2 C' ||
                                  game.category == '2 combo')
                            ? const Color(0xFF9B5DE5)
                            : const Color(0xFFF9C80E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset("lib/assets/images/cardimage.png"),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -20,
                          top: -20,
                          width: 160,
                          height: 110,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.38),
                                  Colors.white.withOpacity(0.0),
                                ],
                                radius: 0.5,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FL Evening',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (game.category == '2 C' ||
                                      game.category == '2 combo')
                                  ? 'Pick 2 combo'
                                  : 'Pick ${game.category}',
                              style: const TextStyle(
                                color: Color(0xFF002C8B),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (game.category != '2 C' &&
                                game.category != '2 combo') ...[
                              const SizedBox(height: 2),
                              Text(
                                game.category == '3D'
                                    ? 'Pick 000-999'
                                    : game.category == '4D'
                                    ? 'Pick 0000-9999'
                                    : game.category == '5D'
                                    ? 'Pick 3+2 D Combo'
                                    : 'Pick 00-99',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // Payout info column
                Stack(
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -20,
                      top: -30,
                      width: 120,
                      height: 110,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.38),
                              Colors.white.withOpacity(0.0),
                            ],
                            radius: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'WIN',
                          style: TextStyle(
                            color: Color(0xFF002C8B),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          game.payout.replaceAll('Payout: ', ''),
                          style: const TextStyle(
                            color: Color(0xFF002C8B),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Dynamic warning banner depending on language & category
    String rangeText = '(00-99)';
    if (game.category == '3D') rangeText = '(000-999)';
    if (game.category == '4D') rangeText = '(0000-9999)';
    if (game.category == '5D') rangeText = '(3+2 D Combo)';
    if (game.category == '2 C' || game.category == '2 combo')
      rangeText = '(2 Combo)';

    final warningBanner = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'pick_number'.tr.replaceAll('(00-99)', rangeText),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFF58220),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF58220),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'warning_sales_limit'.tr,
                style: const TextStyle(color: Color(0xFF78716C), fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );

    // Number Selection Box displaying selected digits with underlines in light grey box
    final selectionBox = GestureDetector(
      onTap: () {
        gameController.activeTarget.value = 'selection';
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: const Border(
            left: BorderSide(color: Color(0xFF0D319C), width: 4),
          ),
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
            Obx(() {
              String selected = gameController.selectedNumbers.value;
              String activeTargetVal = gameController.activeTarget.value;
              int totalLen = game.category == '2D'
                  ? 2
                  : game.category == '3D'
                  ? 3
                  : game.category == '4D'
                  ? 4
                  : game.category == '5D'
                  ? 5
                  : (game.category == '2 C' || game.category == '2 combo')
                  ? 4
                  : 4;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 75,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(totalLen, (index) {
                    String val = 'X';
                    if (index < selected.length) {
                      val = selected[index];
                    }
                    final bool isFilled = val != 'X';
                    final bool isFocused =
                        activeTargetVal == 'selection' &&
                        (index == selected.length ||
                            (selected.length == totalLen &&
                                index == totalLen - 1));

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: index == 0 ? 0 : 8.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            val,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isFilled
                                  ? const Color(0xFF0D319C)
                                  : isFocused
                                  ? AppTheme.primaryOrange
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 14,
                            height: 2,
                            color: isFilled
                                ? const Color(0xFF0D319C)
                                : isFocused
                                ? AppTheme.primaryOrange
                                : const Color(0xFFCBD5E1),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            }),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      gameController.clearSelection();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(
                      'clear_selection'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: gameController.performQuickPick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(0, 40),
                      elevation: 0,
                    ),
                    child: Text(
                      'quick_pick'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Inline selection and bet input details block (displays above keypad)
    final betInputPanelCard = Obx(() {
      String selected = gameController.selectedNumbers.value;
      int requiredLen = game.category == '2D'
          ? 2
          : game.category == '3D'
          ? 3
          : game.category == '4D'
          ? 4
          : game.category == '5D'
          ? 5
          : (game.category == '2 C' || game.category == '2 combo')
          ? 4
          : 4;

      if (selected.length < requiredLen) return const SizedBox();

      final textVal = gameController.enteredAmount.value;
      if (textVal != amountController.text) {
        amountController.value = amountController.value.copyWith(
          text: textVal,
          selection: TextSelection.collapsed(offset: textVal.length),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'your_selection'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                      ),
                    ),
                    if (game.category == '2 C' || game.category == '2 combo')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D319C),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              selected.substring(0, 2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D319C),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              selected.substring(2, 4),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (game.category == '3D' ||
                        game.category == '4D' ||
                        game.category == '5D')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          selected.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 0.0 : 8.0,
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0D319C),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                selected[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D319C),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          selected,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'enter_amount'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      'min_max'.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    gameController.activeTarget.value = 'amount';
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: gameController.activeTarget.value == 'amount'
                            ? AppTheme.primaryOrange
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: amountController,
                        readOnly: true,
                        showCursor:
                            gameController.activeTarget.value == 'amount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D319C),
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    double amount =
                        double.tryParse(gameController.enteredAmount.value) ??
                        0.0;
                    if (gameController.validateBet(amount)) {
                      cartController.addTicket(game.name, selected, amount);
                      _showSuccessDialog(
                        context,
                        gameController,
                        cartController,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryOrange,
                    side: const BorderSide(
                      color: AppTheme.primaryOrange,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                  child: Text(
                    'add_to_cart'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    double amount =
                        double.tryParse(gameController.enteredAmount.value) ??
                        0.0;
                    if (gameController.validateBet(amount)) {
                      cartController.clearCart();
                      cartController.addTicket(game.name, selected, amount);
                      final ticketId = cartController.cartTickets.first.id;

                      final totalAmount = cartController.total;
                      // Execute checkout
                      if (cartController.checkout()) {
                        Get.to(
                          () => BetSuccessView(
                            ticketId: ticketId,
                            gameName: game.name,
                            betNumber: selected,
                            amount: totalAmount,
                          ),
                        );
                        cartController.clearCart();
                        gameController.clearSelection();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(0, 40),
                    elevation: 0,
                  ),
                  child: Text(
                    'buy_ticket'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });

    // Pinned capsule-shaped Keypad Widget
    Widget _buildKeypadButton(String text, VoidCallback onTap) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildBackspaceButton(VoidCallback onTap) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.backspace_outlined,
                color: AppTheme.primaryOrange,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildEmptyButton() {
      return const Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: SizedBox(height: 52),
        ),
      );
    }

    final keypadWidget = Container(
      color: const Color(0xFFE2E8F0),
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildKeypadButton('1', () => gameController.pressKey('1')),
                _buildKeypadButton('2', () => gameController.pressKey('2')),
                _buildKeypadButton('3', () => gameController.pressKey('3')),
              ],
            ),
            Row(
              children: [
                _buildKeypadButton('4', () => gameController.pressKey('4')),
                _buildKeypadButton('5', () => gameController.pressKey('5')),
                _buildKeypadButton('6', () => gameController.pressKey('6')),
              ],
            ),
            Row(
              children: [
                _buildKeypadButton('7', () => gameController.pressKey('7')),
                _buildKeypadButton('8', () => gameController.pressKey('8')),
                _buildKeypadButton('9', () => gameController.pressKey('9')),
              ],
            ),
            Row(
              children: [
                _buildEmptyButton(),
                _buildKeypadButton('0', () => gameController.pressKey('0')),
                _buildBackspaceButton(gameController.pressBackspace),
              ],
            ),
          ],
        ),
      ),
    );

    final scrollBody = Column(
      children: [
        headerCard,
        const SizedBox(height: 12),
        warningBanner,
        const SizedBox(height: 16),
        selectionBox,
        const SizedBox(height: 16),
        betInputPanelCard,
        const SizedBox(height: 16),
      ],
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;
      final orientation = MediaQuery.of(context).orientation;

      String selected = gameController.selectedNumbers.value;
      String activeTargetVal = gameController.activeTarget.value;
      int requiredLen = game.category == '2D'
          ? 2
          : game.category == '3D'
          ? 3
          : game.category == '4D'
          ? 4
          : game.category == '5D'
          ? 5
          : (game.category == '2 C' || game.category == '2 combo')
          ? 4
          : 4;
      final bool isKeypadVisible =
          (selected.length < requiredLen && activeTargetVal == 'selection') ||
          (activeTargetVal == 'amount');

      return Directionality(
        textDirection: textDirection,
        child: GestureDetector(
          onTap: () {
            if (gameController.activeTarget.value == 'amount') {
              gameController.activeTarget.value = 'none';
            }
          },
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
                    const SizedBox(height: 8),
                    Expanded(
                      child: orientation == Orientation.portrait
                          ? Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: scrollBody,
                                  ),
                                ),
                                if (isKeypadVisible) keypadWidget,
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: scrollBody,
                                  ),
                                ),
                                const VerticalDivider(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: SingleChildScrollView(
                                    child: isKeypadVisible
                                        ? keypadWidget
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // Success dialog popup replacing original toast
  void _showSuccessDialog(
    BuildContext context,
    GameController gameController,
    CartController cartController,
  ) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF64748B),
                    size: 16,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 28.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 56,
                    height: 56,
                    child: Image.asset("lib/assets/images/tick.png"),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ticket_added_success'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                            gameController.clearSelection();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryOrange,
                            side: const BorderSide(
                              color: AppTheme.primaryOrange,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            minimumSize: const Size(0, 40),
                          ),
                          child: Text('play_more'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            gameController.clearSelection();
                            Get.to(() => const CartView());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            minimumSize: const Size(0, 40),
                            elevation: 0,
                          ),
                          child: Text('view_cart'.tr),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
