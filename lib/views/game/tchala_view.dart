import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/localization_controller.dart';

class TchalaView extends StatelessWidget {
  const TchalaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameController = Get.put(GameController());
    final localizationController = Get.find<LocalizationController>();

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Text(
              'tchala'.tr,
              style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          backgroundColor: AppTheme.lightGreyBg,
          body: Column(
            children: [
              // Search Input Box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 52,
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
                  child: TextField(
                    onChanged: gameController.filterTchala,
                    decoration: InputDecoration(
                      hintText: 'dream_search'.tr,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // Filtered list result
              Expanded(
                child: Obx(() {
                  final list = gameController.filteredTchala;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('No match found', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.word,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDarkBlue),
                            ),
                            // Row of circles for numbers
                            Row(
                              children: item.numbers.map((number) {
                                return Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  height: 28,
                                  width: 28,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryDarkBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    number,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }
}
