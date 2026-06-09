import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:norbiz_loto/controllers/localization_controller.dart';
import 'package:norbiz_loto/controllers/game_controller.dart';
import 'package:norbiz_loto/models/game_model.dart';
import 'package:flutter/material.dart';

void main() {
  setUp(() {
    // Reset GetX before each test
    Get.reset();
  });

  test('Localization Controller updates active language', () {
    final controller = Get.put(LocalizationController());
    
    // Default is English
    expect(controller.currentLanguage.value, 'en');
    
    // Change language
    controller.changeLanguage('fr');
    expect(controller.currentLanguage.value, 'fr');
  });

  test('Game Controller keypad inputs and selections', () {
    final controller = Get.put(GameController());
    
    final mockGame = GameModel(
      id: 'mock_2d',
      name: 'Mock 2D',
      category: '2D',
      payout: 'x60',
      cardGradient: const LinearGradient(colors: [Colors.red, Colors.blue]),
      minBet: 10.0,
      maxBet: 500.0,
    );
    
    controller.setActiveGame(mockGame);
    
    // Initially empty
    expect(controller.selectedNumbers.value, '');
    
    // Tap digits
    controller.pressKey('7');
    expect(controller.selectedNumbers.value, '7');
    
    controller.pressKey('2');
    expect(controller.selectedNumbers.value, '72');
    
    // Length limit checks (should not exceed 2 digits for 2D)
    controller.pressKey('8');
    expect(controller.selectedNumbers.value, '72');
    
    // Backspace digit
    controller.pressBackspace();
    expect(controller.selectedNumbers.value, '7');
  });

  test('Tchala dream search returns correct matches', () {
    final controller = Get.put(GameController());
    
    // Search for Poison/Poisson/Fish
    controller.filterTchala('Fish');
    expect(controller.filteredTchala.length, 1);
    expect(controller.filteredTchala.first.word, 'Fish');
    
    // Clear search
    controller.filterTchala('');
    expect(controller.filteredTchala.length, controller.tchalaList.length);
  });
}
