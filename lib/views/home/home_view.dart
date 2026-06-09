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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      () => Row(
                        children: [
                          Expanded(
                            child: GameCard(game: homeController.games[0]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GameCard(game: homeController.games[1]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GameCard(game: homeController.games[2]),
                          ),
                        ],
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

                    // Time Selection Dropdown Bar
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
                              Text(
                                '9:45 PM ET',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
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
                    const SizedBox(height: 24),

                    // Game Play Section Title
                    Text(
                      'Borlette 2D',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Agent Play Cards List
                    _buildAgentPlayCard(
                      agentName: 'Agent Bon Chans',
                      drawName: 'FL Evening',
                      nextDrawTime: '9:45 PM (Evening)',
                      gameCategory: '2D',
                      payout: 'x60 x20 x10',
                      hasBorder: false,
                      onTap: () {
                        final borlette = homeController.games.firstWhere(
                          (g) => g.id == 'borlette_2d',
                        );
                        Get.to(() => BorletteView(game: borlette));
                      },
                    ),
                    _buildAgentPlayCard(
                      agentName: 'Agent Royale',
                      drawName: 'FL Evening',
                      nextDrawTime: '9:45 PM (Evening)',
                      gameCategory: '2D',
                      payout: 'x60 x20 x10',
                      hasBorder: false,
                      onTap: () {
                        final borlette = homeController.games.firstWhere(
                          (g) => g.id == 'borlette_2d',
                        );
                        Get.to(() => BorletteView(game: borlette));
                      },
                    ),
                    _buildAgentPlayCard(
                      agentName: 'Agent Lucky Soleil',
                      drawName: 'FL Evening',
                      nextDrawTime: '9:45 PM (Evening)',
                      gameCategory: '2D',
                      payout: 'x60 x20 x10',
                      hasBorder: false,
                      onTap: () {
                        final borlette = homeController.games.firstWhere(
                          (g) => g.id == 'borlette_2d',
                        );
                        Get.to(() => BorletteView(game: borlette));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDBB13), Color(0xFFFE9900)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
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
                            color: const Color(0xFFB59A30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Top cluster (small decorative balls)
                              Positioned(
                                top: 6,
                                left: 14,
                                child: _buildBall(
                                  '',
                                  Colors.lightBlue,
                                  size: 8,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                left: 24,
                                child: _buildBall(
                                  '',
                                  Colors.greenAccent,
                                  size: 12,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 14,
                                child: _buildBall(
                                  '',
                                  Colors.purpleAccent,
                                  size: 10,
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: 20,
                                child: _buildBall('', Colors.yellow, size: 9),
                              ),

                              // Main foreground balls
                              // Blue Ball '1' (bottom left)
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: _buildBall(
                                  '1',
                                  Colors.blue,
                                  size: 22,
                                  fontSize: 11,
                                ),
                              ),
                              // Red Ball '7' (middle/right)
                              Positioned(
                                bottom: 12,
                                right: 18,
                                child: _buildBall(
                                  '7',
                                  Colors.red,
                                  size: 18,
                                  fontSize: 9,
                                ),
                              ),
                              // Green Ball '8' (bottom right)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: _buildBall(
                                  '8',
                                  Colors.green,
                                  size: 20,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              'Pick $gameCategory',
                              style: const TextStyle(
                                color: Color(0xFF002C8B),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pick 00-99',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Payout info column
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
    return GestureDetector(
      onTap: () => Get.to(() => BorletteView(game: game)),
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
