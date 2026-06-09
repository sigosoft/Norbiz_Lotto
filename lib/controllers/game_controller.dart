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

  // Tchala list and search
  var tchalaList = <DreamModel>[].obs;
  var filteredTchala = <DreamModel>[].obs;
  var tchalaSearchQuery = ''.obs;

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
          .where((item) =>
              item.word.toLowerCase().contains(query.toLowerCase()) ||
              item.numbers.any((n) => n.contains(query)))
          .toList();
    }
  }

  // Keypad presses
  void pressKey(String char) {
    int maxLen = 2; // Default for 2D
    if (activeGame.category == '3D') maxLen = 3;
    if (activeGame.category == '4D') maxLen = 4;

    if (selectedNumbers.value.length < maxLen) {
      selectedNumbers.value += char;
    }
  }

  void pressBackspace() {
    if (selectedNumbers.value.isNotEmpty) {
      selectedNumbers.value = selectedNumbers.value.substring(0, selectedNumbers.value.length - 1);
    }
  }

  void clearSelection() {
    selectedNumbers.value = '';
    enteredAmount.value = '';
  }

  void performQuickPick() {
    int len = 2;
    if (activeGame.category == '3D') len = 3;
    if (activeGame.category == '4D') len = 4;
    
    // Generate random digits
    var random = DateTime.now().millisecond;
    String picks = '';
    for (int i = 0; i < len; i++) {
      picks += ((random + i * 7) % 10).toString();
    }
    selectedNumbers.value = picks;
  }

  // Validation
  bool validateBet(double amount) {
    // Simulate sales limit limit block for '99' or '9,9' matching the warning screen
    if (selectedNumbers.value == '99' || selectedNumbers.value == '999' || selectedNumbers.value == '9999') {
      showNumberUnavailableModal(selectedNumbers.value);
      return false;
    }

    return true;
  }

  void showNumberUnavailableModal(String number) {
    // Standard GetX bottom sheet/dialog matching figma
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              Text(
                'number_limit_title'.trParams({'num': number}),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'number_limit_desc'.tr,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('choose_another'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
