import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';
import '../models/dream_model.dart';
import '../configs/api_config.dart';
import '../configs/toast.dart';
import 'cart_controller.dart';

class GameController extends GetxController {
  // Active game selected
  late GameModel activeGame;

  // Selected numbers state
  var selectedNumbers = ''.obs;
  var enteredAmount = ''.obs;
  var activeTarget = 'selection'.obs;
  var isQuickPicked = false.obs;

  // Tchala list and search
  var tchalaList = <DreamModel>[].obs;
  var filteredTchala = <DreamModel>[].obs;
  var tchalaSearchQuery = ''.obs;
  final tchalaController = TextEditingController();
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadTchalaDictionary();
  }

  void setActiveGame(GameModel game) {
    activeGame = game;
    clearSelection();
  }

  void loadTchalaDictionary() {
    var data = [
      DreamModel(word: 'Fish', numbers: ['02', '00', '20']),
      DreamModel(word: 'Poisson', numbers: ['02', '00', '20']),
      DreamModel(word: 'Pwason', numbers: ['02', '00', '20']),
      DreamModel(word: 'Snake', numbers: ['34', '43', '03']),
      DreamModel(word: 'Serpent', numbers: ['34', '43', '03']),
      DreamModel(word: 'Koulèv', numbers: ['34', '43', '03']),
      DreamModel(word: 'Money', numbers: ['22', '45', '75']),
      DreamModel(word: 'Argent', numbers: ['22', '45', '75']),
      DreamModel(word: 'Lajan', numbers: ['22', '45', '75']),
      DreamModel(word: 'Death', numbers: ['90', '09', '99']),
      DreamModel(word: 'Mort', numbers: ['90', '09', '99']),
      DreamModel(word: 'Lanmò', numbers: ['90', '09', '99']),
      DreamModel(word: 'Water', numbers: ['06', '60', '16']),
      DreamModel(word: 'Eau', numbers: ['06', '60', '16']),
      DreamModel(word: 'Dlo', numbers: ['06', '60', '16']),
      DreamModel(word: 'Fire', numbers: ['12', '21', '02']),
      DreamModel(word: 'Feu', numbers: ['12', '21', '02']),
      DreamModel(word: 'Dife', numbers: ['12', '21', '02']),
      DreamModel(word: 'Blood', numbers: ['08', '80', '18']),
      DreamModel(word: 'Sang', numbers: ['08', '80', '18']),
      DreamModel(word: 'San', numbers: ['08', '80', '18']),
    ];
    tchalaList.value = data;
    filteredTchala.value = data;
  }

  void filterTchala(String query) {
    tchalaSearchQuery.value = query;
    if (query.isEmpty) {
      filteredTchala.value = tchalaList;
    } else {
      // Local filter first for instant UI response
      filteredTchala.value = tchalaList
          .where(
            (item) =>
                item.word.toLowerCase().contains(query.toLowerCase()) ||
                item.numbers.any((n) => n.contains(query)),
          )
          .toList();

      // Debounce and trigger API search
      _searchDebounceTimer?.cancel();
      _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
        searchTchalaApi(query);
      });
    }
  }

  Future<void> searchTchalaApi(String query) async {
    if (query.isEmpty) return;

    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url =
          '${ApiConfig.baseUrl}${ApiConfig.tchalaSearch}?q=${Uri.encodeComponent(query)}';
      debugPrint('=== TCHALA SEARCH API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== TCHALA SEARCH RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      // If the user has typed something else in the meantime, discard this response
      if (tchalaController.text != query) {
        debugPrint(
          'Discarding search response for "$query" as current input is "${tchalaController.text}"',
        );
        return;
      }

      if (response.statusCode == 200 && response.body != null) {
        final dataMap = response.body;
        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'];
          if (data != null && data['results'] != null) {
            final resultsList = data['results'] as List;
            final List<DreamModel> apiResults = [];
            for (var item in resultsList) {
              if (item is Map) {
                final word =
                    (item['word'] ??
                            item['title'] ??
                            item['name'] ??
                            item['dream'] ??
                            '')
                        .toString();
                final rawNumbers = item['numbers'] ?? item['number'] ?? [];

                List<String> parsedNumbers = [];
                if (rawNumbers is List) {
                  parsedNumbers = rawNumbers
                      .map((e) => e.toString().trim())
                      .toList();
                } else if (rawNumbers is String) {
                  if (rawNumbers.contains(',')) {
                    parsedNumbers = rawNumbers
                        .split(',')
                        .map((e) => e.trim())
                        .toList();
                  } else if (rawNumbers.contains('-')) {
                    parsedNumbers = rawNumbers
                        .split('-')
                        .map((e) => e.trim())
                        .toList();
                  } else if (rawNumbers.contains(' ')) {
                    parsedNumbers = rawNumbers
                        .split(RegExp(r'\s+'))
                        .map((e) => e.trim())
                        .toList();
                  } else {
                    parsedNumbers = [rawNumbers.trim()];
                  }
                }

                apiResults.add(DreamModel(word: word, numbers: parsedNumbers));
              }
            }

            // Merge API results with the local filtered results to prevent results from disappearing
            final List<DreamModel> merged = List<DreamModel>.from(apiResults);
            final localFiltered = tchalaList
                .where(
                  (item) =>
                      item.word.toLowerCase().contains(query.toLowerCase()) ||
                      item.numbers.any((n) => n.contains(query)),
                )
                .toList();

            for (var localItem in localFiltered) {
              final alreadyExists = merged.any(
                (m) =>
                    m.word.trim().toLowerCase() ==
                    localItem.word.trim().toLowerCase(),
              );
              if (!alreadyExists) {
                merged.add(localItem);
              }
            }

            filteredTchala.value = merged;
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching Tchala API: $e');
      // local filter remains active
    }
  }

  // Keypad presses
  void pressKey(String char) {
    int maxLen = 2; // Default for 2D
    if (activeGame.category == '3D') maxLen = 3;
    if (activeGame.category == '4D') maxLen = 4;
    if (activeGame.category == '5D') maxLen = 5;
    if (activeGame.category == '2 C' || activeGame.category == '2 combo')
      maxLen = 4;

    if (activeTarget.value == 'selection') {
      isQuickPicked.value = false;
      if (selectedNumbers.value.length < maxLen) {
        selectedNumbers.value += char;
      }
      if (selectedNumbers.value.length == maxLen) {
        activeTarget.value = 'none';
      }
    } else if (activeTarget.value == 'amount') {
      if (enteredAmount.value.length < 5) {
        enteredAmount.value += char;
      }
    }
  }

  void pressBackspace() {
    isQuickPicked.value = false;
    if (activeTarget.value == 'amount') {
      if (enteredAmount.value.isNotEmpty) {
        enteredAmount.value = enteredAmount.value.substring(
          0,
          enteredAmount.value.length - 1,
        );
      } else {
        activeTarget.value = 'selection';
        if (selectedNumbers.value.isNotEmpty) {
          selectedNumbers.value = selectedNumbers.value.substring(
            0,
            selectedNumbers.value.length - 1,
          );
        }
      }
    } else {
      if (selectedNumbers.value.isNotEmpty) {
        selectedNumbers.value = selectedNumbers.value.substring(
          0,
          selectedNumbers.value.length - 1,
        );
      }
    }
  }

  void clearSelection() {
    selectedNumbers.value = '';
    enteredAmount.value = '';
    activeTarget.value = 'none';
    isQuickPicked.value = false;
  }

  Future<void> performQuickPick() async {
    int gameTypeId = 1;
    if (activeGame.rawBoardData != null &&
        activeGame.rawBoardData!['game_type_id'] != null) {
      gameTypeId =
          int.tryParse(activeGame.rawBoardData!['game_type_id'].toString()) ??
          1;
    } else {
      final name = activeGame.id.toLowerCase();
      if (name.contains('borlette'))
        gameTypeId = 1;
      else if (name.contains('maryaj') || name.contains('marriage'))
        gameTypeId = 2;
      else if (name.contains('3d') || name.contains('loto3'))
        gameTypeId = 3;
      else if (name.contains('4d') || name.contains('loto4'))
        gameTypeId = 4;
      else if (name.contains('5d') || name.contains('loto5'))
        gameTypeId = 5;
    }

    int drawId = 1;
    if (activeGame.rawBoardData != null) {
      final raw = activeGame.rawBoardData!;
      final rawDrawId =
          raw['draw_id'] ??
          raw['draw_session_id'] ??
          raw['draw_session']?['id'] ??
          raw['id'];
      if (rawDrawId != null) {
        drawId = int.tryParse(rawDrawId.toString()) ?? 1;
      }
    }

    final String currentSelection = selectedNumbers.value.trim();
    final bool hasEnteredNumber = currentSelection.isNotEmpty;

    debugPrint('=== performQuickPick ===');
    debugPrint('Current Selection: "$currentSelection"');
    debugPrint('Has Entered Number: $hasEnteredNumber');

    if (hasEnteredNumber) {
      // Scenario A: User entered a number manually.
      // Call ONLY the tickets/validate API (don't call quick-pick API).
      String numberPrimary = currentSelection;
      String numberSecondary = '';
      final isMaryaj =
          activeGame.name.toLowerCase().contains('maryaj') ||
          activeGame.name.toLowerCase().contains('marriage') ||
          activeGame.id.toLowerCase().contains('maryaj') ||
          activeGame.id.toLowerCase().contains('marriage');
      if (isMaryaj && currentSelection.length >= 4) {
        numberPrimary = currentSelection.substring(0, 2);
        numberSecondary = currentSelection.substring(2, 4);
      }

      double amount = double.tryParse(enteredAmount.value) ?? activeGame.minBet;
      if (amount <= 0.0) {
        amount = activeGame.minBet > 0 ? activeGame.minBet : 1.0;
      }

      try {
        final cartController = Get.find<CartController>();
        final bool isValidated = await cartController.validateTicket(
          drawId: drawId,
          gameTypeId: gameTypeId,
          numberPrimary: numberPrimary,
          numberSecondary: numberSecondary,
          betAmount: amount,
        );

        if (isValidated) {
          activeTarget.value = 'none';
          isQuickPicked.value = true;
        }
      } catch (e) {
        debugPrint('Error validating entered number: $e');
        showToast('Validation failed. Please try again.', title: 'Error');
      }
    } else {
      // Scenario B: User did NOT enter a number.
      // Call BOTH quick-pick and validate APIs.
      try {
        final connect = GetConnect();
        connect.timeout = const Duration(seconds: 15);

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final Map<String, String> headers = {};
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }

        final String url =
            '${ApiConfig.baseUrl}${ApiConfig.quickPick}?game_type_id=$gameTypeId';
        debugPrint('=== QUICK PICK API CALL ===');
        debugPrint('URL: $url');
        debugPrint('Headers: $headers');

        final response = await connect.get(url, headers: headers);

        debugPrint('=== QUICK PICK RESPONSE ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');

        if (response.statusCode == 200 && response.body != null) {
          final dataMap = response.body;
          if (dataMap['status'] == 'true' || dataMap['status'] == true) {
            final data = dataMap['data'];
            if (data != null && data['numbers'] != null) {
              final numbers = data['numbers'];
              final primary = numbers['number_primary']?.toString() ?? '';
              final secondary = numbers['number_secondary']?.toString() ?? '';

              String generatedNumbers = '';
              if (secondary.isNotEmpty) {
                generatedNumbers = primary + secondary;
              } else {
                generatedNumbers = primary;
              }

              // Call validate API on the generated number
              String tempPrimary = primary;
              String tempSecondary = secondary;
              final isMaryaj =
                  activeGame.name.toLowerCase().contains('maryaj') ||
                  activeGame.name.toLowerCase().contains('marriage') ||
                  activeGame.id.toLowerCase().contains('maryaj') ||
                  activeGame.id.toLowerCase().contains('marriage');
              if (isMaryaj && generatedNumbers.length >= 4) {
                tempPrimary = generatedNumbers.substring(0, 2);
                tempSecondary = generatedNumbers.substring(2, 4);
              }

              double amount =
                  double.tryParse(enteredAmount.value) ?? activeGame.minBet;
              if (amount <= 0.0) {
                amount = activeGame.minBet > 0 ? activeGame.minBet : 1.0;
              }

              final cartController = Get.find<CartController>();
              final bool isValidated = await cartController.validateTicket(
                drawId: drawId,
                gameTypeId: gameTypeId,
                numberPrimary: tempPrimary,
                numberSecondary: tempSecondary,
                betAmount: amount,
              );

              if (isValidated) {
                selectedNumbers.value = generatedNumbers;
                activeTarget.value = 'none';
                isQuickPicked.value = true;
              }
            }
          } else {
            final dynamic errMsg = dataMap['message'] != null
                ? dataMap['message']
                : 'Failed to generate quick pick numbers.';
            showToast(errMsg, title: 'Error');
          }
        } else {
          showToast('Server error. Please try again.', title: 'Error');
        }
      } catch (e) {
        debugPrint('Error performing quick pick / validation: $e');
        showToast('An error occurred. Please try again.', title: 'Error');
      }
    }
  }

  // Validation
  bool validateBet(double amount) {
    // Simulate sales limit limit block for '99' or '9,9' matching the warning screen
    if (selectedNumbers.value == '99' ||
        selectedNumbers.value == '999' ||
        selectedNumbers.value == '9999' ||
        selectedNumbers.value == '99999') {
      showNumberUnavailableModal(selectedNumbers.value);
      return false;
    }

    return true;
  }

  void showNumberUnavailableModal(String number) {
    final formattedNumber = number.split('').join(',');
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'number_limit_title'.trParams({'num': formattedNumber}),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'number_limit_desc'.tr,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE9900),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                        elevation: 0,
                      ),
                      child: Text('choose_another'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchAndShowRules(int gameTypeId, String gameName) async {
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url =
          '${ApiConfig.baseUrl}${ApiConfig.gamesRules}?game_type_id=$gameTypeId';
      debugPrint('=== GAMES RULES API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D319C)),
          ),
        ),
        barrierDismissible: false,
      );

      final response = await connect.get(url, headers: headers);

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      debugPrint('=== GAMES RULES API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      String rulesText = '';

      if (response.statusCode == 200 && response.body != null) {
        final dataMap = response.body;
        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'];
          if (data != null) {
            final rulesObj = data['rules'] ?? data['game'] ?? data;
            if (rulesObj is Map) {
              final lang = Get.locale?.languageCode ?? 'en';
              final ruleVal =
                  rulesObj['rules_$lang'] ??
                  rulesObj['rule_$lang'] ??
                  rulesObj['description_$lang'] ??
                  rulesObj['rules'] ??
                  rulesObj['rule'] ??
                  rulesObj['description'] ??
                  rulesObj['rules_en'] ??
                  rulesObj['rule_en'] ??
                  rulesObj['description_en'];
              if (ruleVal != null) {
                rulesText = ruleVal.toString();
              }
            }
          }
        }
      }

      if (rulesText.isEmpty) {
        rulesText = 'No rules available for this game.';
      }

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(gameName),
          content: SingleChildScrollView(child: Text(rulesText)),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
          ],
        ),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint('Error fetching game rules: $e');
      showToast('Failed to load rules. Please try again.', title: 'Error');
    }
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    tchalaController.dispose();
    super.onClose();
  }
}
