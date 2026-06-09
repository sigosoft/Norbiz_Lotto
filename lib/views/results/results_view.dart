import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/results_controller.dart';
import '../../controllers/localization_controller.dart';

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
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Text(
              'results'.tr,
              style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          backgroundColor: AppTheme.lightGreyBg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: resultsController.filterResults,
                    decoration: const InputDecoration(
                      hintText: 'Search by lottery or draw',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // Filter State Tabs
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: resultsController.stateTabs.length,
                  itemBuilder: (context, index) {
                    final tab = resultsController.stateTabs[index];
                    return Obx(() {
                      final isSelected = resultsController.selectedStateTab.value == tab;
                      return GestureDetector(
                        onTap: () => resultsController.changeStateTab(tab),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryOrange : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.primaryDarkBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Date Picker Button Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: resultsController.selectedDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          resultsController.updateDate(picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined, size: 14),
                      label: Obx(() => Text(resultsController.formattedSelectedDate)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryDarkBlue,
                        side: BorderSide(color: Colors.grey.shade300),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(120, 38),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List Results
              Expanded(
                child: Obx(() {
                  final list = resultsController.filteredResults;
                  if (list.isEmpty) {
                    return const Center(child: Text('No draw results for this selection.'));
                  }
                  
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryDarkBlue),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getTagColor(item.gameType).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.gameType,
                                    style: TextStyle(
                                      color: _getTagColor(item.gameType),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Draw Result', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 6),
                            Row(
                              children: item.drawNumbers.map((num) => _buildCircle(num, Colors.grey.shade100, Colors.black87)).toList(),
                            ),
                            const SizedBox(height: 12),
                            const Text('Winning Numbers', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 6),
                            Row(
                              children: item.winningNumbers.map((num) => _buildCircle(num, AppTheme.primaryDarkBlue, Colors.white, size: 36)).toList(),
                            ),
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

  Color _getTagColor(String type) {
    if (type == 'Borlette') return const Color(0xFFFFB800);
    if (type == 'Lotto 3') return const Color(0xFF0288D1);
    if (type == 'Lotto 4') return const Color(0xFFC2185B);
    return const Color(0xFF2E7D32);
  }

  Widget _buildCircle(String num, Color bg, Color textCol, {double size = 28}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        num,
        style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: size > 30 ? 12 : 11),
      ),
    );
  }
}
