import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../configs/api_config.dart';

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
  var selectedDate = DateTime(
    2026,
    3,
    11,
  ).obs; // Matches March 11, 2026 in Figma
  var searchQuery = ''.obs;

  var stateTabs = ['Florida', 'New York', 'Georgia', 'Texas seals'];

  String get formattedSelectedDate =>
      DateFormat('MMM dd, yyyy').format(selectedDate.value);

  // Mock draw results database
  var resultsList = <DrawResultItem>[].obs;
  var filteredResults = <DrawResultItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadResults();
    fetchDrawResults();
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
      DrawResultItem(
        title: 'FL Midday',
        gameType: 'Borlette',
        drawNumbers: ['1', '3', '4', '5', '0', '8', '9'],
        winningNumbers: ['13', '45', '08'],
      ),
      DrawResultItem(
        title: 'FL Midday',
        gameType: 'Lotto 3',
        drawNumbers: ['1', '3', '4', '5', '0', '8', '9'],
        winningNumbers: ['1', '3', '4'],
      ),
      DrawResultItem(
        title: 'FL Midday',
        gameType: 'Lotto 4',
        drawNumbers: ['1', '3', '4', '5', '0', '8', '9'],
        winningNumbers: ['1', '3', '4', '5'],
      ),
      DrawResultItem(
        title: 'FL Midday',
        gameType: 'Lotto 5',
        drawNumbers: ['1', '3', '4', '5', '0', '8', '9'],
        winningNumbers: ['134', '50', '89'],
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
          .where(
            (item) =>
                item.gameType.toLowerCase().contains(query.toLowerCase()) ||
                item.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  Future<void> fetchDrawResults({String drawId = '1'}) async {
    isLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final List<DrawResultItem> loadedResults = [];

      // 1. Call the requested api results/show?draw_id=<drawId>&game_type_id=
      final String url =
          '${ApiConfig.baseUrl}${ApiConfig.resultsShow}?draw_id=$drawId&game_type_id=';
      debugPrint('=== FETCH RESULTS SHOW API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);
      debugPrint('=== FETCH RESULTS SHOW RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        final dynamic resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          dataMap = {};
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final dynamic rawData = dataMap['data'];
          final Map<String, dynamic> data = rawData is Map
              ? Map<String, dynamic>.from(rawData)
              : <String, dynamic>{};

          final Map<String, dynamic> result = data['result'] != null
              ? Map<String, dynamic>.from(data['result'])
              : <String, dynamic>{};

          if (result.isNotEmpty) {
            // Check if game_results exists inside result
            if (result['game_results'] is List) {
              final String lotterySource = result['lottery_source'] ?? 'FL';
              final String sessionType = result['session_type'] ?? 'Midday';
              final String title = '$lotterySource $sessionType';

              final List<String> drawNumbers = [];
              if (result['draw_digits'] is List) {
                drawNumbers.addAll(
                  (result['draw_digits'] as List).map((e) => e.toString()),
                );
              } else if (result['combined_draw_number'] != null) {
                drawNumbers.addAll(
                  result['combined_draw_number'].toString().split(''),
                );
              }

              for (var gameRes in result['game_results']) {
                if (gameRes is Map) {
                  String gameType = gameRes['game_name_en']?.toString() ?? '';
                  if (gameType.toLowerCase().contains('borlette')) {
                    gameType = 'Borlette';
                  } else if (gameType.toLowerCase().contains('loto 3') ||
                      gameType.toLowerCase().contains('lotto 3')) {
                    gameType = 'Lotto 3';
                  } else if (gameType.toLowerCase().contains('loto 4') ||
                      gameType.toLowerCase().contains('lotto 4')) {
                    gameType = 'Lotto 4';
                  } else if (gameType.toLowerCase().contains('loto 5') ||
                      gameType.toLowerCase().contains('lotto 5')) {
                    gameType = 'Lotto 5';
                  }

                  final List<String> winningNumbers = [];
                  if (gameRes['winning_numbers'] is List) {
                    winningNumbers.addAll(
                      (gameRes['winning_numbers'] as List).map(
                        (e) => e.toString(),
                      ),
                    );
                  }

                  loadedResults.add(
                    DrawResultItem(
                      title: title,
                      gameType: gameType.isEmpty ? 'Borlette' : gameType,
                      drawNumbers: drawNumbers,
                      winningNumbers: winningNumbers,
                    ),
                  );
                }
              }
            }
          }

          // Fallback to parse standard structure if game_results was not processed
          if (loadedResults.isEmpty && result.isNotEmpty) {
            List<dynamic> itemsList = [];
            if (rawData is List) {
              itemsList = rawData;
            } else if (data['results'] is List) {
              itemsList = data['results'];
            } else if (data['result'] is List) {
              itemsList = data['result'];
            } else if (data['draws'] is List) {
              itemsList = data['draws'];
            } else if (data['result'] is Map) {
              itemsList = [data['result']];
            }

            if (itemsList.isEmpty) {
              if (dataMap['results'] is List) {
                itemsList = dataMap['results'];
              } else if (dataMap['result'] is List) {
                itemsList = dataMap['result'];
              } else if (dataMap['result'] is Map) {
                itemsList = [dataMap['result']];
              }
            }

            for (var item in itemsList) {
              if (item is Map) {
                final resultItem = _parseResultItem(
                  Map<String, dynamic>.from(item),
                );
                if (resultItem != null) {
                  loadedResults.add(resultItem);
                }
              }
            }
          }
        }
      }

      // 2. Query each game type individually to populate results for all game types (Borlette, Lotto 3, Lotto 4, Lotto 5) if still empty
      if (loadedResults.isEmpty) {
        final List<int> gameTypeIds = [1, 3, 4, 5];
        for (int gameTypeId in gameTypeIds) {
          final String loopUrl =
              '${ApiConfig.baseUrl}${ApiConfig.resultsShow}?draw_id=$drawId&game_type_id=$gameTypeId';
          final loopResponse = await connect.get(loopUrl, headers: headers);

          if (loopResponse.statusCode == 200 && loopResponse.body != null) {
            final resData = loopResponse.body;
            Map<String, dynamic> dataMap;
            if (resData is String) {
              dataMap = Map<String, dynamic>.from(jsonDecode(resData));
            } else if (resData is Map) {
              dataMap = Map<String, dynamic>.from(resData);
            } else {
              continue;
            }

            if (dataMap['status'] == 'true' || dataMap['status'] == true) {
              final Map<String, dynamic> data = dataMap['data'] != null
                  ? Map<String, dynamic>.from(dataMap['data'])
                  : <String, dynamic>{};
              final Map<String, dynamic> result = data['result'] != null
                  ? Map<String, dynamic>.from(data['result'])
                  : <String, dynamic>{};

              if (result.isNotEmpty) {
                bool parsedFromGameResults = false;
                if (result['game_results'] is List) {
                  final String lotterySource = result['lottery_source'] ?? 'FL';
                  final String sessionType = result['session_type'] ?? 'Midday';
                  final String title = '$lotterySource $sessionType';

                  final List<String> drawNumbers = [];
                  if (result['draw_digits'] is List) {
                    drawNumbers.addAll(
                      (result['draw_digits'] as List).map((e) => e.toString()),
                    );
                  } else if (result['combined_draw_number'] != null) {
                    drawNumbers.addAll(
                      result['combined_draw_number'].toString().split(''),
                    );
                  }

                  for (var gameRes in result['game_results']) {
                    if (gameRes is Map) {
                      String gameType =
                          gameRes['game_name_en']?.toString() ?? '';
                      if (gameType.toLowerCase().contains('borlette')) {
                        gameType = 'Borlette';
                      } else if (gameType.toLowerCase().contains('loto 3') ||
                          gameType.toLowerCase().contains('lotto 3')) {
                        gameType = 'Lotto 3';
                      } else if (gameType.toLowerCase().contains('loto 4') ||
                          gameType.toLowerCase().contains('lotto 4')) {
                        gameType = 'Lotto 4';
                      } else if (gameType.toLowerCase().contains('loto 5') ||
                          gameType.toLowerCase().contains('lotto 5')) {
                        gameType = 'Lotto 5';
                      }

                      final List<String> winningNumbers = [];
                      if (gameRes['winning_numbers'] is List) {
                        winningNumbers.addAll(
                          (gameRes['winning_numbers'] as List).map(
                            (e) => e.toString(),
                          ),
                        );
                      }

                      final newItem = DrawResultItem(
                        title: title,
                        gameType: gameType.isEmpty ? 'Borlette' : gameType,
                        drawNumbers: drawNumbers,
                        winningNumbers: winningNumbers,
                      );

                      final alreadyExists = loadedResults.any(
                        (item) =>
                            item.gameType == newItem.gameType &&
                            item.title == newItem.title,
                      );
                      if (!alreadyExists) {
                        loadedResults.add(newItem);
                      }
                      parsedFromGameResults = true;
                    }
                  }
                }

                if (!parsedFromGameResults) {
                  final resultItem = _parseResultItem(result);
                  if (resultItem != null) {
                    final alreadyExists = loadedResults.any(
                      (item) =>
                          item.gameType == resultItem.gameType &&
                          item.title == resultItem.title,
                    );
                    if (!alreadyExists) {
                      loadedResults.add(resultItem);
                    }
                  }
                }
              }
            }
          }
        }
      }

      if (loadedResults.isNotEmpty) {
        resultsList.value = loadedResults;
        filterResults(searchQuery.value);
      }
    } catch (e) {
      debugPrint('Error fetching draw results: $e');
    } finally {
      isLoading.value = false;
    }
  }

  DrawResultItem? _parseResultItem(Map<String, dynamic> result) {
    if (result.isEmpty) return null;

    final String title =
        '${result['lottery_source'] ?? 'FL'} ${result['session_type'] ?? 'Midday'}';
    final String gameType = result['game_type']?.toString() ?? '';
    final String firstPrize = result['first_prize']?.toString() ?? '';
    final String secondPrize = result['second_prize']?.toString() ?? '';
    final String thirdPrize = result['third_prize']?.toString() ?? '';

    // Construct drawNumbers (all digits concatenated)
    final List<String> drawNumbers = [];
    if (firstPrize.isNotEmpty) {
      drawNumbers.addAll(firstPrize.split(''));
    }
    if (secondPrize.isNotEmpty) {
      drawNumbers.addAll(secondPrize.split(''));
    }
    if (thirdPrize.isNotEmpty) {
      drawNumbers.addAll(thirdPrize.split(''));
    }

    // Construct winningNumbers based on gameType
    final List<String> winningNumbers = [];
    if (gameType == 'Borlette') {
      if (firstPrize.length >= 2) {
        winningNumbers.add(firstPrize.substring(firstPrize.length - 2));
      } else {
        winningNumbers.add(firstPrize);
      }
      winningNumbers.add(secondPrize);
      winningNumbers.add(thirdPrize);
    } else if (gameType == 'Lotto 3') {
      if (firstPrize.isNotEmpty) {
        winningNumbers.addAll(firstPrize.split(''));
      }
    } else if (gameType == 'Lotto 4') {
      final allDigits = [...drawNumbers];
      if (allDigits.length >= 4) {
        winningNumbers.addAll(allDigits.sublist(0, 4));
      } else {
        winningNumbers.addAll(allDigits);
      }
    } else if (gameType == 'Lotto 5' || gameType.contains('5')) {
      winningNumbers.add(firstPrize);
      winningNumbers.add(secondPrize);
      winningNumbers.add(thirdPrize);
    } else {
      winningNumbers.add(firstPrize);
      winningNumbers.add(secondPrize);
      winningNumbers.add(thirdPrize);
    }

    return DrawResultItem(
      title: title,
      gameType: gameType.isEmpty ? 'Borlette' : gameType,
      drawNumbers: drawNumbers,
      winningNumbers: winningNumbers,
    );
  }
}
