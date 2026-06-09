import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../models/ticket_model.dart';
import '../../controllers/bet_history_controller.dart';
import '../../controllers/localization_controller.dart';

class BetHistoryView extends StatelessWidget {
  const BetHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final historyController = Get.put(BetHistoryController());
    final localizationController = Get.find<LocalizationController>();

    final emptyWidget = Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: AppTheme.lightGreyBg, shape: BoxShape.circle),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Colors.grey,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_bet_history'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryDarkBlue),
            ),
          ],
        ),
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Text(
              'bet_history'.tr,
              style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          backgroundColor: AppTheme.lightGreyBg,
          body: Column(
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
                    onChanged: historyController.updateSearch,
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

              // Capsule Filters
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['All', 'Pending', 'Won', 'Loss'].map((filter) {
                    return Obx(() {
                      final isSelected = historyController.activeFilter.value == filter;
                      return GestureDetector(
                        onTap: () => historyController.changeFilter(filter),
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
                            filter == 'Loss' ? 'loss'.tr : filter == 'Won' ? 'won'.tr : filter == 'Pending' ? 'pending'.tr : 'all_bets'.tr,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.primaryDarkBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // History list results
              Expanded(
                child: Obx(() {
                  final list = historyController.filteredTickets;
                  if (list.isEmpty) return emptyWidget;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ticket = list[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ticket ID: ${ticket.id}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
                                ),
                                _buildStatusTag(ticket.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(color: AppTheme.primaryDarkBlue, shape: BoxShape.circle),
                                  child: Text(
                                    ticket.numbers,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${ticket.betAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue, fontSize: 14),
                                    ),
                                    if (ticket.status == TicketStatus.won && ticket.winAmount != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '+\$${ticket.winAmount!.toStringAsFixed(2)}',
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ] else if (ticket.status == TicketStatus.lost && ticket.winAmount != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '-\$${ticket.betAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ]
                                  ],
                                ),
                              ],
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

  Widget _buildStatusTag(TicketStatus status) {
    String label = 'PENDING';
    Color bg = Colors.amber.shade50;
    Color textCol = Colors.amber.shade800;
    
    if (status == TicketStatus.won) {
      label = 'WIN';
      bg = Colors.green.shade50;
      textCol = Colors.green.shade800;
    } else if (status == TicketStatus.lost) {
      label = 'LOSS';
      bg = Colors.red.shade50;
      textCol = Colors.red.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: textCol),
      ),
    );
  }
}
