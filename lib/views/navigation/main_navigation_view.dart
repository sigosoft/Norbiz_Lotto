import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/localization_controller.dart';
import '../../configs/theme.dart';
import '../home/home_view.dart';
import '../results/results_view.dart';
import '../bet_history/bet_history_view.dart';
import '../game/tchala_view.dart';
import '../account/account_view.dart';

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  Widget build(key) {
    final homeController = Get.find<HomeController>();
    final localizationController = Get.find<LocalizationController>();

    final List<Widget> pages = [
      const HomeView(),
      const ResultsView(),
      const BetHistoryView(),
      const TchalaView(),
      const AccountView(),
    ];

    return Obx(() {
      final isRtl = localizationController.isRtl.value;
      final orientation = MediaQuery.of(key).orientation;
      final selectedIndex = homeController.currentNavIndex.value;

      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          body: orientation == Orientation.portrait
              ? IndexedStack(index: selectedIndex, children: pages)
              : Row(
                  children: [
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: homeController.changeNavIndex,
                      labelType: NavigationRailLabelType.all,
                      selectedIconTheme: const IconThemeData(
                        color: AppTheme.primaryOrange,
                      ),
                      unselectedIconTheme: const IconThemeData(
                        color: Colors.grey,
                      ),
                      selectedLabelTextStyle: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                      destinations: [
                        NavigationRailDestination(
                          icon: const ImageIcon(
                            AssetImage('lib/assets/images/BottomHome.png'),
                          ),
                          label: Text('home'.tr),
                        ),
                        NavigationRailDestination(
                          icon: const ImageIcon(
                            AssetImage('lib/assets/images/BottomResult.png'),
                          ),
                          label: Text('results'.tr),
                        ),
                        NavigationRailDestination(
                          icon: const ImageIcon(
                            AssetImage(
                              'lib/assets/images/BottomBetHistory.png',
                            ),
                          ),
                          label: Text('bet_history'.tr),
                        ),
                        NavigationRailDestination(
                          icon: const ImageIcon(
                            AssetImage('lib/assets/images/BottomTchala.png'),
                          ),
                          label: Text('tchala'.tr),
                        ),
                        NavigationRailDestination(
                          icon: const ImageIcon(
                            AssetImage('lib/assets/images/BottomProfile.png'),
                          ),
                          label: Text('account'.tr),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: pages,
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: orientation == Orientation.portrait
              ? BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: homeController.changeNavIndex,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppTheme.primaryOrange,
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  items: [
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('lib/assets/images/BottomHome.png'),
                      ),
                      label: 'home'.tr,
                    ),
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('lib/assets/images/BottomResult.png'),
                      ),
                      label: 'results'.tr,
                    ),
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('lib/assets/images/BottomBetHistory.png'),
                      ),
                      label: 'bet_history'.tr,
                    ),
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('lib/assets/images/BottomTchala.png'),
                      ),
                      label: 'tchala'.tr,
                    ),
                    BottomNavigationBarItem(
                      icon: const ImageIcon(
                        AssetImage('lib/assets/images/BottomProfile.png'),
                      ),
                      label: 'account'.tr,
                    ),
                  ],
                )
              : null,
        ),
      );
    });
  }
}
