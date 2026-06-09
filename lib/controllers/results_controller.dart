import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DrawResultItem {
  final String title;
  final String gameType; // 'Borlette', 'Lotto 3', 'Lotto 4', 'Lotto 5'
  final List<String> drawNumbers;
  final List<String> winningNumbers;

  DrawResultItem({
    required this.title,
    required this.gameType,
    required this.drawNumbers,
    required this.winningNumbers,
  });
}

class ResultsController extends GetxController {
  var selectedStateTab = 'Florida'.obs;
  var selectedDate = DateTime(2026, 3, 11).obs; // Matches March 11, 2026 in Figma
  var searchQuery = ''.obs;

  var stateTabs = ['Florida', 'New York', 'Georgia', 'Texas'];

  String get formattedSelectedDate => DateFormat('MMM dd, yyyy').format(selectedDate.value);

  // Mock draw results database
  var resultsList = <DrawResultItem>[].obs;
  var filteredResults = <DrawResultItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadResults();
  }

  void loadResults() {
    var data = [
      DrawResultItem(
        title: 'FL Midday',
        gameType: 'Borlette',
        drawNumbers: ['4', '7', '2', '8', '3', '1', '6'],
        winningNumbers: ['47', '28', '31'],
      ),
      DrawResultItem(
        title: 'FL Midday',
        gameType: 'Lotto 3',
        drawNumbers: ['4', '7', '2', '8', '3', '1', '6'],
        winningNumbers: ['4', '7', '2'],
      ),
      DrawResultItem(
        title: 'FL Midday',
        gameType: 'Lotto 4',
        drawNumbers: ['4', '7', '2', '8', '3', '1', '6'],
        winningNumbers: ['4', '7', '2', '8'],
      ),
      DrawResultItem(
        title: 'FL Midday',
        gameType: 'Lotto 5',
        drawNumbers: ['4', '7', '2', '8', '3', '1', '6'],
        winningNumbers: ['472', '83', '16'],
      ),
    ];
    resultsList.value = data;
    filteredResults.value = data;
  }

  void changeStateTab(String state) {
    selectedStateTab.value = state;
    // Realistically update draws based on state
  }

  void updateDate(DateTime date) {
    selectedDate.value = date;
  }

  void filterResults(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredResults.value = resultsList;
    } else {
      filteredResults.value = resultsList
          .where((item) =>
              item.gameType.toLowerCase().contains(query.toLowerCase()) ||
              item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
