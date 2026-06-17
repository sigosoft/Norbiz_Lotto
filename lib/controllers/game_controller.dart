import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/game_model.dart';
import '../models/dream_model.dart';

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
      filteredTchala.value = tchalaList
          .where(
            (item) =>
                item.word.toLowerCase().contains(query.toLowerCase()) ||
                item.numbers.any((n) => n.contains(query)),
          )
          .toList();
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

  void performQuickPick() {
    int len = 2;
    if (activeGame.category == '3D') len = 3;
    if (activeGame.category == '4D') len = 4;
    if (activeGame.category == '5D') len = 5;
    if (activeGame.category == '2 C' || activeGame.category == '2 combo')
      len = 4;

    // Generate random digits
    var random = DateTime.now().millisecond;
    String picks = '';
    for (int i = 0; i < len; i++) {
      picks += ((random + i * 7) % 10).toString();
    }
    selectedNumbers.value = picks;
    activeTarget.value = 'none';
    isQuickPicked.value = true;
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

  @override
  void onClose() {
    tchalaController.dispose();
    super.onClose();
  }
}
