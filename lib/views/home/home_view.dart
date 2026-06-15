import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:norbiz_loto/models/game_model.dart';
import '../../configs/theme.dart';
import '../../configs/toast.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/localization_controller.dart';
import '../../controllers/cart_controller.dart';
import '../game/borlette_view.dart';
import '../cart/cart_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final cartController = Get.put(CartController());
    final localizationController = Get.find<LocalizationController>();

    // Header Action Row
    final headerRow = Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo
          Image.asset(
            'lib/assets/images/Logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),

          // Notifications & Cart button
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1E293B),
                  size: 26,
                ),
                onPressed: () {
                  showToast('no_notifications'.tr, title: 'Notifications');
                },
              ),
              const SizedBox(width: 4),
              Obx(
                () => GestureDetector(
                  onTap: () => Get.to(() => const CartView()),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 24,
                      top: 10,
                      bottom: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D319C),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'cart'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (cartController.cartTickets.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.buttonOrange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cartController.cartTickets.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Jackpot Slider Banner
    final bannerCarousel = Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            onPageChanged: (idx) =>
                homeController.currentCarouselIndex.value = idx,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('lib/assets/images/caurosal slider.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: homeController.currentCarouselIndex.value == index
                      ? const Color(0xFFFE9900)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerRow,
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bannerCarousel,
                          const SizedBox(height: 24),

                          Text(
                            'choose_game'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Game Selection Category Cards
                          Obx(
                            () => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              child: Row(
                                children: List.generate(
                                  homeController.games.length,
                                  (index) {
                                    final game = homeController.games[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right:
                                            index == homeController.games.length - 1
                                            ? 0.0
                                            : 12.0,
                                      ),
                                      child: SizedBox(
                                        width: 106,
                                        child: GameCard(game: game),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Search Bar
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF94A3B8),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: homeController.filterGames,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'search_placeholder'.tr,
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      filled: false,
                                      isDense: true,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5EA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.dark_mode_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'FL Evening',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    RealTimeClock(),
                                    SizedBox(width: 78),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF1E293B),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Centered Play & Win Badge
                          Center(
                            child: Image.asset(
                              'lib/assets/images/Play&Win.png',
                              height: 60,
                              width: 320,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Game Play Section Title & Agent Play Cards List
                          Obx(() {
                            final selectedGame = homeController.games.firstWhere(
                              (g) => g.id == homeController.selectedGameId.value,
                              orElse: () => homeController.games.first,
                            );

                            final String gameTitle =
                                selectedGame.id == 'borlette_2d'
                                ? '${selectedGame.name} ${selectedGame.category}'
                                : selectedGame.name;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gameTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildAgentPlayCard(
                                  agentName: 'Agent Bon Chans',
                                  drawName: 'FL Evening',
                                  nextDrawTime: '9:45 PM (Evening)',
                                  gameCategory: selectedGame.category,
                                  payout: selectedGame.payout.replaceAll(
                                    'Payout: ',
                                    '',
                                  ),
                                  hasBorder: false,
                                  onTap: () {
                                    Get.to(() => BorletteView(game: selectedGame));
                                  },
                                ),
                                _buildAgentPlayCard(
                                  agentName: 'Agent Royale',
                                  drawName: 'FL Evening',
                                  nextDrawTime: '9:45 PM (Evening)',
                                  gameCategory: selectedGame.category,
                                  payout: selectedGame.payout.replaceAll(
                                    'Payout: ',
                                    '',
                                  ),
                                  hasBorder: false,
                                  onTap: () {
                                    Get.to(() => BorletteView(game: selectedGame));
                                  },
                                ),
                                _buildAgentPlayCard(
                                  agentName: 'Agent Lucky Soleil',
                                  drawName: 'FL Evening',
                                  nextDrawTime: '9:45 PM (Evening)',
                                  gameCategory: selectedGame.category,
                                  payout: selectedGame.payout.replaceAll(
                                    'Payout: ',
                                    '',
                                  ),
                                  hasBorder: false,
                                  onTap: () {
                                    Get.to(() => BorletteView(game: selectedGame));
                                  },
                                ),
                              ],
                            );
                          }),
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

  // Helper widget to build a lottery ball inside the gold square
  Widget _buildBall(
    String number,
    Color color, {
    Color textColor = Colors.white,
    double size = 18,
    double fontSize = 10,
  }) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color.withOpacity(0.8), color],
          center: const Alignment(-0.3, -0.3),
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: number.isEmpty
          ? null
          : Text(
              number,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  // Agent Play Card Builder
  Widget _buildAgentPlayCard({
    required String agentName,
    required String drawName,
    required String nextDrawTime,
    required String gameCategory,
    required String payout,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) {
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: AppTheme.loginSheetBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Agent Header Band
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  agentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Next Draw is $nextDrawTime',
                  style: const TextStyle(
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
              gradient: gameCategory == '3D'
                  ? AppTheme.lotto3Gradient
                  : gameCategory == '4D'
                  ? AppTheme.lotto4Gradient
                  : gameCategory == '5D'
                  ? AppTheme.lotto5Gradient
                  : (gameCategory == '2 C' || gameCategory == '2 combo')
                  ? AppTheme.maryajGradient
                  : AppTheme.borletteGradient,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Column with Logo & Draw Details
                    Row(
                      children: [
                        // Balls square graphic mock
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: gameCategory == '3D'
                                ? const Color.fromARGB(255, 81, 126, 199)
                                : gameCategory == '4D'
                                ? const Color.fromARGB(255, 179, 81, 81)
                                : gameCategory == '5D'
                                ? const Color.fromARGB(255, 70, 168, 111)
                                : (gameCategory == '2 C' ||
                                      gameCategory == '2 combo')
                                ? const Color.fromARGB(255, 120, 77, 174)
                                : const Color.fromARGB(255, 203, 174, 72),
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
                                Text(
                                  drawName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (gameCategory == '2 C' ||
                                          gameCategory == '2 combo')
                                      ? 'Pick 2 combo'
                                      : 'Pick $gameCategory',
                                  style: const TextStyle(
                                    color: Color(0xFF002C8B),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (gameCategory != '2 C' &&
                                    gameCategory != '2 combo') ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    gameCategory == '3D'
                                        ? 'Pick 000-999'
                                        : gameCategory == '4D'
                                        ? 'Pick 0000-9999'
                                        : gameCategory == '5D'
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
                              payout,
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
                const SizedBox(height: 16),
                // Play Button inside card
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.loginSheetBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Play',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (hasBorder) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: const Color(0xFF0091FF), width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: cardContent,
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: cardContent,
      );
    }
  }
}

class GameCard extends StatelessWidget {
  final GameModel game;
  const GameCard({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return GestureDetector(
      onTap: () => homeController.selectedGameId.value = game.id,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            height: 90,
            margin: const EdgeInsets.only(top: 18),
            padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
            decoration: BoxDecoration(
              gradient: game.cardGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: game.cardGradient.colors.last.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  game.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.payout,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: game.cardGradient.colors.first,
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                game.category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF002C8B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RealTimeClock extends StatefulWidget {
  const RealTimeClock({Key? key}) : super(key: key);

  @override
  State<RealTimeClock> createState() => _RealTimeClockState();
}

class _RealTimeClockState extends State<RealTimeClock> {
  late String _timeString;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${DateFormat('h:mm a').format(dateTime)} ET';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}
