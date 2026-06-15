import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/results_controller.dart';
import '../../controllers/localization_controller.dart';
import '../../controllers/home_controller.dart';

class ResultsView extends StatelessWidget {
  const ResultsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resultsController = Get.put(ResultsController());
    final localizationController = Get.find<LocalizationController>();

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
                  // Custom App Bar / Header Row
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
                          'results'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ), // Spacer to balance the back button
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
                        onChanged: resultsController.filterResults,
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

                  // Dropdown & Date Picker Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'All Lottery',
                                  style: TextStyle(
                                    color: AppTheme.primaryDarkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    resultsController.selectedDate.value,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                resultsController.updateDate(picked);
                              }
                            },
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Obx(
                                    () => Text(
                                      resultsController.formattedSelectedDate,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter State Tabs
                  Container(
                    width: double.infinity,
                    height: 44,
                    color: const Color(0xFFDCE3F6).withOpacity(0.5),
                    child: Obx(() {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: resultsController.stateTabs.map((tab) {
                          final isSelected =
                              resultsController.selectedStateTab.value == tab;
                          return GestureDetector(
                            onTap: () => resultsController.changeStateTab(tab),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Spacer(),
                                  Text(
                                    tab,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFFE9900)
                                          : const Color(0xFF707E94),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 3,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFE9900)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),

                  // List Results
                  Expanded(
                    child: Obx(() {
                      final list = resultsController.filteredResults;
                      if (list.isEmpty) {
                        return const Center(
                          child: Text('No draw results for this selection.'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final showHeader =
                              index == 0 ||
                              !_areListsEqual(
                                list[index].drawNumbers,
                                list[index - 1].drawNumbers,
                              );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showHeader)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 12.0,
                                  ),
                                  child: Text(
                                    '${item.title} Draw – ${resultsController.formattedSelectedDate}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppTheme.primaryDarkBlue,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: _getTagColor(
                                                item.gameType,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            item.gameType,
                                            style: TextStyle(
                                              color: _getTagColor(
                                                item.gameType,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Draw Result',
                                      style: TextStyle(
                                        color: Color(0xFF707E94),
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: item.drawNumbers
                                          .map(
                                            (num) => _buildCircle(num, false),
                                          )
                                          .toList(),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Winning',
                                      style: TextStyle(
                                        color: Color(0xFF707E94),
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: item.winningNumbers
                                          .map((num) => _buildCircle(num, true))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Color _getTagColor(String type) {
    if (type == 'Borlette') return const Color(0xFFFFC53D);
    if (type == 'Lotto 3') return const Color(0xFF5CACEE);
    if (type == 'Lotto 4') return const Color(0xFFFF7B7B);
    return const Color(0xFF2CD46B);
  }

  Widget _buildCircle(String num, bool isWinning, {double size = 32}) {
    final themeColor = const Color(0xFF002C8B);
    return Container(
      margin: const EdgeInsets.only(right: 6),
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isWinning ? themeColor : Colors.white,
        shape: BoxShape.circle,
        border: isWinning ? null : Border.all(color: themeColor, width: 1),
      ),
      child: Text(
        num,
        style: TextStyle(
          color: isWinning ? Colors.white : themeColor,
          fontWeight: FontWeight.bold,
          fontSize: num.length > 2 ? 10 : 12,
        ),
      ),
    );
  }
}
