import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';
import '../configs/theme.dart';
import '../configs/api_config.dart';
import 'game_controller.dart';
import 'localization_controller.dart';

class HomeController extends GetxController {
  // Navigation
  var currentNavIndex = 0.obs;

  // Carousel
  var currentCarouselIndex = 0.obs;

  // Loading state
  var isLoading = false.obs;

  // Dynamic lists from home API
  var banners = <dynamic>[].obs;
  var gameTabs = <dynamic>[].obs;
  var drawFilters = <dynamic>[].obs;
  var gameBoard = <dynamic>[].obs;

  // Selected filters
  var selectedGameTypeId = 1.obs;
  var selectedDrawSessionId = Rxn<int>();
  var searchQuery = ''.obs;

  // Games list
  var games = <GameModel>[].obs;
  var filteredGames = <GameModel>[].obs;
  var selectedGameId = 'borlette_2d'.obs;

  // Wallet
  var walletBalance = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();

    // Set up reactive listeners to auto-fetch when selections change
    ever(selectedGameId, (_) {
      fetchHomeData();
    });
    ever(selectedDrawSessionId, (_) {
      fetchHomeData();
    });
  }

  Future<void> fetchHomeData() async {
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

      int gameTypeId = 1;
      switch (selectedGameId.value) {
        case 'borlette':
        case 'borlette_2d':
          gameTypeId = 1;
          break;
        case 'marriage':
        case 'maryaj':
          gameTypeId = 2;
          break;
        case 'loto3':
        case 'lotto_3d':
          gameTypeId = 3;
          break;
        case 'loto4':
        case 'lotto_4d':
          gameTypeId = 4;
          break;
        case 'loto5':
        case 'lotto_5d':
          gameTypeId = 5;
          break;
      }
      selectedGameTypeId.value = gameTypeId;

      final drawSessionStr = selectedDrawSessionId.value != null
          ? selectedDrawSessionId.value.toString()
          : '';
      final url =
          '${ApiConfig.baseUrl}${ApiConfig.home}?game_type_id=$gameTypeId&draw_session_id=$drawSessionStr&search=${Uri.encodeComponent(searchQuery.value)}';

      debugPrint('=== FETCH HOME API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH HOME RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.body != null) {
        final dynamic resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          debugPrint('Unexpected response body type: ${resData.runtimeType}');
          return;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : {};

          banners.value = data['banners'] != null
              ? List<dynamic>.from(data['banners'])
              : [];
          gameTabs.value = data['game_tabs'] != null
              ? List<dynamic>.from(data['game_tabs'])
              : [];
          drawFilters.value = data['draw_filters'] != null
              ? List<dynamic>.from(data['draw_filters'])
              : [];
          gameBoard.value = data['game_board'] != null
              ? List<dynamic>.from(data['game_board'])
              : [];

          final wallet = data['wallet'];
          if (wallet != null) {
            final balance =
                double.tryParse(wallet['balance']?.toString() ?? '0.0') ?? 0.0;
            walletBalance.value = balance;
          } else {
            walletBalance.value = null;
          }

          _loadGamesFromTabs(gameTabs);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching home data: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  void _loadGamesFromTabs(List<dynamic> tabs) {
    final localizationController = Get.find<LocalizationController>();
    final lang = localizationController.currentLanguage.value;

    // Define the exact card order from the previous UI design
    const Map<String, int> slugOrder = {
      'borlette': 0,
      'loto3': 1,
      'loto4': 2,
      'loto5': 3,
      'marriage': 4,
    };

    final sortedTabs = List<dynamic>.from(tabs);
    sortedTabs.sort((a, b) {
      final slugA = a['slug'] ?? '';
      final slugB = b['slug'] ?? '';
      final orderA = slugOrder[slugA] ?? 99;
      final orderB = slugOrder[slugB] ?? 99;
      return orderA.compareTo(orderB);
    });

    final List<GameModel> list = [];
    for (var tab in sortedTabs) {
      final tabMap = Map<String, dynamic>.from(tab);
      final String slug = tabMap['slug'] ?? '';
      final int digitCount =
          int.tryParse(tabMap['digit_count']?.toString() ?? '2') ?? 2;

      String category = '${digitCount}D';
      if (slug == 'marriage' || slug == 'maryaj') {
        category = '2 C';
      }

      String name = tabMap['name_en'] ?? '';
      if (lang == 'fr') {
        name = tabMap['name_fr'] ?? tabMap['name_en'] ?? '';
      } else if (lang == 'ht') {
        name = tabMap['name_ht'] ?? tabMap['name_en'] ?? '';
      }

      // Restore the card name to "Maryaj" (for English/Marriage slug) to match UI
      if (slug == 'marriage' || slug == 'maryaj') {
        name = 'Maryaj';
      }

      Gradient gradient;
      switch (slug) {
        case 'borlette':
          gradient = AppTheme.borletteGradient;
          break;
        case 'loto3':
          gradient = AppTheme.lotto3Gradient;
          break;
        case 'loto4':
          gradient = AppTheme.lotto4Gradient;
          break;
        case 'loto5':
          gradient = AppTheme.lotto5Gradient;
          break;
        case 'marriage':
        case 'maryaj':
          gradient = AppTheme.maryajGradient;
          break;
        default:
          gradient = AppTheme.borletteGradient;
      }

      String localId = slug;
      if (slug == 'borlette') localId = 'borlette_2d';
      if (slug == 'marriage') localId = 'maryaj';
      if (slug == 'loto3') localId = 'lotto_3d';
      if (slug == 'loto4') localId = 'lotto_4d';
      if (slug == 'loto5') localId = 'lotto_5d';

      final payoutLabel = tabMap['payout_label'] ?? '';

      double minBet = 1.0;
      double maxBet = 1000.0;
      final multipliers = tabMap['multipliers'] != null
          ? List<dynamic>.from(tabMap['multipliers'])
          : null;
      if (multipliers != null && multipliers.isNotEmpty) {
        minBet =
            double.tryParse(multipliers[0]['min_bet']?.toString() ?? '1.0') ??
            1.0;
        maxBet =
            double.tryParse(
              multipliers[0]['max_bet_per_number']?.toString() ?? '1000.0',
            ) ??
            1000.0;
      }

      list.add(
        GameModel(
          id: localId,
          name: name,
          payout: 'Payout: $payoutLabel',
          category: category,
          cardGradient: gradient,
          minBet: minBet,
          maxBet: maxBet,
        ),
      );
    }

    games.value = list;
    filteredGames.value = list;
  }

  void loadGames() {
    fetchHomeData();
  }

  void filterGames(String query) {
    searchQuery.value = query;
    fetchHomeData();
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
