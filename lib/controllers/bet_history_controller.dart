import 'package:get/get.dart';
import '../models/ticket_model.dart';

class BetHistoryController extends GetxController {
  var activeFilter = 'All'.obs; // 'All', 'Pending', 'Won', 'Loss'
  var searchQuery = ''.obs;

  var allTickets = <TicketModel>[].obs;
  var filteredTickets = <TicketModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockHistory();
  }

  void loadMockHistory() {
    var data = [
      TicketModel(
        id: '#447856',
        gameName: 'Brolette FL Midday',
        numbers: '09',
        date: 'MAR 11, 2026 • 2:00 PM',
        betAmount: 10.0,
        status: TicketStatus.pending,
      ),
      TicketModel(
        id: '#447855',
        gameName: 'Brolette FL Midday',
        numbers: '25',
        date: 'MAR 11, 2026 • 2:00 PM',
        betAmount: 10.0,
        winAmount: 600.0,
        status: TicketStatus.won,
      ),
      TicketModel(
        id: '#447854',
        gameName: 'Brolette FL Midday',
        numbers: '09',
        date: 'MAR 11, 2026 • 2:00 PM',
        betAmount: 10.0,
        winAmount: -10.0,
        status: TicketStatus.lost,
      ),
    ];
    allTickets.value = data;
    applyFilters();
  }

  void changeFilter(String filter) {
    activeFilter.value = filter;
    applyFilters();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    List<TicketModel> results = allTickets;

    // Filter by tab
    if (activeFilter.value == 'Pending') {
      results = results.where((t) => t.status == TicketStatus.pending).toList();
    } else if (activeFilter.value == 'Won') {
      results = results.where((t) => t.status == TicketStatus.won).toList();
    } else if (activeFilter.value == 'Loss') {
      results = results.where((t) => t.status == TicketStatus.lost).toList();
    }

    // Filter by search
    if (searchQuery.value.isNotEmpty) {
      results = results
          .where((t) =>
              t.id.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              t.gameName.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    filteredTickets.value = results;
  }
}
