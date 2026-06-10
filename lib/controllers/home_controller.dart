import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../configs/theme.dart';
import 'game_controller.dart';

class HomeController extends GetxController {
  // Navigation
  var currentNavIndex = 0.obs;

  // Carousel
  var currentCarouselIndex = 0.obs;

  // Games list
  var games = <GameModel>[].obs;
  var filteredGames = <GameModel>[].obs;
  var selectedGameId = 'borlette_2d'.obs;

  // Search
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadGames();
  }

  void loadGames() {
    var gameList = [
      GameModel(
        id: 'borlette_2d',
        name: 'Borlette',
        payout: 'Payout: x60 x20 x10',
        category: '2D',
        cardGradient: AppTheme.borletteGradient,
        minBet: 10.0,
        maxBet: 500.0,
      ),
      GameModel(
        id: 'lotto_3d',
        name: 'Lotto 3',
        payout: 'Payout: x500',
        category: '3D',
        cardGradient: AppTheme.lotto3Gradient,
        minBet: 10.0,
        maxBet: 500.0,
      ),
      GameModel(
        id: 'lotto_4d',
        name: 'Lotto 4',
        payout: 'Payout: x4,500',
        category: '4D',
        cardGradient: AppTheme.lotto4Gradient,
        minBet: 10.0,
        maxBet: 500.0,
      ),
      GameModel(
        id: 'lotto_5d',
        name: 'Lotto 5',
        payout: 'Payout: x50,000',
        category: '5D',
        cardGradient: AppTheme.lotto5Gradient,
        minBet: 10.0,
        maxBet: 500.0,
      ),
      GameModel(
        id: 'maryaj',
        name: 'Maryaj',
        payout: 'Payout: x50,000',
        category: '2 C',
        cardGradient: AppTheme.maryajGradient,
        minBet: 10.0,
        maxBet: 500.0,
      ),
    ];
    games.value = gameList;
    filteredGames.value = gameList;
  }

  void filterGames(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredGames.value = games;
    } else {
      filteredGames.value = games
          .where((game) =>
              game.name.toLowerCase().contains(query.toLowerCase()) ||
              game.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
    if (index == 3) {
      try {
        final gameController = Get.find<GameController>();
        gameController.tchalaController.clear();
        gameController.tchalaSearchQuery.value = '';
      } catch (_) {}
    }
  }
}
