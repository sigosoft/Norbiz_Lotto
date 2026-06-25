import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';
import '../configs/theme.dart';
import '../configs/api_config.dart';
import 'game_controller.dart';
import 'localization_controller.dart';
import 'auth_controller.dart';
import 'bet_history_controller.dart';
import 'results_controller.dart';
import '../views/game/borlette_view.dart';


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

    // Reactively update game model translations when language changes
    final localizationController = Get.find<LocalizationController>();
    ever(localizationController.currentLanguage, (_) {
      if (gameTabs.isNotEmpty) {
        _loadGamesFromTabs(gameTabs);
      }
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
      debugPrint('Response Body: ${response.body}');

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
          final rawGameBoard = data['game_board'] != null
              ? List<dynamic>.from(data['game_board'])
              : [];

          debugPrint('Found ${rawGameBoard.length} items in rawGameBoard');

          final List<Map<String, dynamic>> updatedGameBoard = [];
          final List<Future<void>> fetchFutures = [];

          for (var item in rawGameBoard) {
            final boardMap = Map<String, dynamic>.from(item);
            updatedGameBoard.add(boardMap);

            // Extract the draw session ID using fallback keys for maximum compatibility
            final drawSessionId =
                boardMap['draw_session_id'] ??
                boardMap['draw_session']?['id'] ??
                boardMap['draw_id'] ??
                boardMap['id'];

            debugPrint(
              'Iterating gameBoard item, resolved drawSessionId: $drawSessionId',
            );
            if (drawSessionId != null) {
              debugPrint(
                'Scheduling fetchUpcomingDraw for drawSessionId: $drawSessionId',
              );
              fetchFutures.add(() async {
                try {
                  final upcomingDraw = await fetchUpcomingDraw(
                    drawSessionId.toString(),
                    token,
                  );
                  debugPrint(
                    'fetchUpcomingDraw returned for drawSessionId: $drawSessionId, hasData: ${upcomingDraw != null}',
                  );
                  if (upcomingDraw != null) {
                    debugPrint(
                      'Upcoming draw data for drawSessionId $drawSessionId: $upcomingDraw',
                    );
                    boardMap['draw_session_name_en'] =
                        upcomingDraw['name_en'] ??
                        boardMap['draw_session_name_en'];
                    boardMap['draw_session_name_fr'] =
                        upcomingDraw['name_fr'] ??
                        boardMap['draw_session_name_fr'];
                    boardMap['draw_session_name_ht'] =
                        upcomingDraw['name_ht'] ??
                        boardMap['draw_session_name_ht'];

                    final officialTime = upcomingDraw['official_draw_time']
                        ?.toString();
                    final tz = upcomingDraw['timezone']?.toString();
                    if (officialTime != null && officialTime.isNotEmpty) {
                      boardMap['next_draw_label_en'] = formatDrawTime(
                        officialTime,
                        tz,
                        'en',
                      );
                      boardMap['next_draw_label_fr'] = formatDrawTime(
                        officialTime,
                        tz,
                        'fr',
                      );
                      boardMap['next_draw_label_ht'] = formatDrawTime(
                        officialTime,
                        tz,
                        'ht',
                      );
                    } else {
                      boardMap['next_draw_label_en'] =
                          upcomingDraw['next_draw_label_en'] ??
                          boardMap['next_draw_label_en'];
                      boardMap['next_draw_label_fr'] =
                          upcomingDraw['next_draw_label_fr'] ??
                          boardMap['next_draw_label_fr'];
                      boardMap['next_draw_label_ht'] =
                          upcomingDraw['next_draw_label_ht'] ??
                          boardMap['next_draw_label_ht'];
                    }

                    boardMap['agent_name_en'] =
                        upcomingDraw['agent_name_en'] ??
                        boardMap['agent_name_en'];
                    boardMap['agent_name_fr'] =
                        upcomingDraw['agent_name_fr'] ??
                        boardMap['agent_name_fr'];
                    boardMap['agent_name_ht'] =
                        upcomingDraw['agent_name_ht'] ??
                        boardMap['agent_name_ht'];
                  }
                } catch (err) {
                  debugPrint(
                    'Error updating boardMap with upcoming draw: $err',
                  );
                }
              }());
            }
          }

          if (fetchFutures.isNotEmpty) {
            debugPrint(
              'Waiting for ${fetchFutures.length} upcoming draw calls...',
            );
            await Future.wait(fetchFutures);
            debugPrint('Done waiting for upcoming draw calls.');
          }

          gameBoard.value = updatedGameBoard;

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
          payout: 'payout_label_format'.trParams({'label': payoutLabel}),
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
    debugPrint('=== changeNavIndex called with index: $index ===');
    currentNavIndex.value = index;
    if (index == 1) {
      try {
        if (Get.isRegistered<ResultsController>()) {
          Get.find<ResultsController>().fetchDrawResults();
        } else {
          final resultsController = Get.put(ResultsController());
          resultsController.fetchDrawResults();
        }
      } catch (e) {
        debugPrint('Error triggering fetchDrawResults: $e');
      }
    } else if (index == 2) {
      try {
        if (Get.isRegistered<BetHistoryController>()) {
          Get.find<BetHistoryController>().fetchBetHistory();
        }
      } catch (_) {}
    } else if (index == 3) {
      try {
        final gameController = Get.find<GameController>();
        gameController.tchalaController.clear();
        gameController.tchalaSearchQuery.value = '';
      } catch (_) {}
    } else if (index == 4) {
      try {
        final authController = Get.find<AuthController>();
        authController.fetchProfile();
        authController.fetchWallet();
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>?> fetchUpcomingDraw(
    String drawSessionId,
    String? token,
  ) async {
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 10);

      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final url =
          '${ApiConfig.baseUrl}${ApiConfig.upcomingDraws}?draw_session_id=$drawSessionId';
      debugPrint('=== FETCH UPCOMING DRAW API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);
      debugPrint('=== FETCH UPCOMING DRAW RESPONSE ===');
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
          debugPrint(
            'Unexpected response body type for upcoming draw: ${resData.runtimeType}',
          );
          return null;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'];
          if (data != null &&
              data['draws'] is List &&
              (data['draws'] as List).isNotEmpty) {
            return Map<String, dynamic>.from(data['draws'][0]);
          } else {
            debugPrint('No upcoming draws list or empty draws array in data');
          }
        } else {
          debugPrint(
            'Status field in upcoming draw response was not true: ${dataMap['status']}',
          );
        }
      } else {
        debugPrint(
          'Failed to get upcoming draw response: Status code ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in fetchUpcomingDraw: $e');
    }
    return null;
  }

  void clearData() {
    banners.clear();
    gameTabs.clear();
    drawFilters.clear();
    gameBoard.clear();
    walletBalance.value = null;
  }

  String formatDrawTime(String? timeStr, String? timezone, String lang) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.isNotEmpty) {
        int hour = int.parse(parts[0]);
        int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
        final minuteStr = minute.toString().padLeft(2, '0');

        final isET =
            timezone != null && timezone.toLowerCase().contains('new_york');

        if (lang == 'fr') {
          final tzSuffix = isET ? ' HE' : '';
          return '${hour}h$minuteStr$tzSuffix';
        } else {
          final ampm = hour >= 12 ? 'PM' : 'AM';
          final hour12 = hour % 12 == 0 ? 12 : hour % 12;
          final tzSuffix = isET ? ' ET' : '';
          return '$hour12:$minuteStr $ampm$tzSuffix';
        }
      }
    } catch (e) {
      debugPrint('Error formatting draw time: $e');
    }
    return timeStr;
  }

  Future<Map<String, dynamic>?> fetchPlayDetails(
    String drawId,
    String gameTypeId,
    String? token,
  ) async {
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final url =
          '${ApiConfig.baseUrl}${ApiConfig.ticketsPlay}?draw_id=$drawId&game_type_id=$gameTypeId';
      debugPrint('=== FETCH TICKETS PLAY API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);
      debugPrint('=== FETCH TICKETS PLAY RESPONSE ===');
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
          debugPrint(
            'Unexpected response body type for tickets play: ${resData.runtimeType}',
          );
          return null;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'];
          if (data != null && data['play'] is Map) {
            return Map<String, dynamic>.from(data['play']);
          }
        }
      }
    } catch (e) {
      debugPrint('Error in fetchPlayDetails: $e');
    }
    return null;
  }

  Future<void> playGame(
    Map<String, dynamic> board,
    GameModel selectedGame,
  ) async {
    isLoading.value = true;
    try {
      final drawId =
          board['draw_id'] ?? board['draw_session_id'] ?? board['id'];
      final gameTypeId = board['game_type_id'] ?? selectedGameTypeId.value;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final playDetails = await fetchPlayDetails(
        drawId.toString(),
        gameTypeId.toString(),
        token,
      );

      final updatedBoard = Map<String, dynamic>.from(board);
      if (playDetails != null) {
        updatedBoard.addAll(playDetails);
      }

      final localizationController = Get.find<LocalizationController>();
      final activeLang = localizationController.currentLanguage.value;

      String agentName = updatedBoard['agent_name_en'] ?? '';
      if (activeLang == 'fr') {
        agentName =
            updatedBoard['agent_name_fr'] ??
            updatedBoard['agent_name_en'] ??
            '';
      } else if (activeLang == 'ht') {
        agentName =
            updatedBoard['agent_name_ht'] ??
            updatedBoard['agent_name_en'] ??
            '';
      }

      String drawName = updatedBoard['draw_session_name_en'] ?? '';
      if (activeLang == 'fr') {
        drawName =
            updatedBoard['draw_session_name_fr'] ??
            updatedBoard['draw_session_name_en'] ??
            '';
      } else if (activeLang == 'ht') {
        drawName =
            updatedBoard['draw_session_name_ht'] ??
            updatedBoard['draw_session_name_en'] ??
            '';
      }

      String nextDrawTime = updatedBoard['next_draw_label_en'] ?? '';
      final officialTime = updatedBoard['official_draw_time']?.toString();
      final tz = updatedBoard['timezone']?.toString();
      if (officialTime != null && officialTime.isNotEmpty) {
        nextDrawTime = formatDrawTime(officialTime, tz, activeLang);
      } else {
        if (activeLang == 'fr') {
          nextDrawTime =
              updatedBoard['next_draw_label_fr'] ??
              updatedBoard['next_draw_label_en'] ??
              '';
        } else if (activeLang == 'ht') {
          nextDrawTime =
              updatedBoard['next_draw_label_ht'] ??
              updatedBoard['next_draw_label_en'] ??
              '';
        }
      }

      final boardGameModel = GameModel(
        id: selectedGame.id,
        name: selectedGame.name,
        payout: selectedGame.payout,
        category: selectedGame.category,
        cardGradient: selectedGame.cardGradient,
        minBet: selectedGame.minBet,
        maxBet: selectedGame.maxBet,
        agentName: agentName.isNotEmpty ? agentName : selectedGame.agentName,
        drawName: drawName.isNotEmpty ? drawName : selectedGame.drawName,
        nextDrawTime: nextDrawTime.isNotEmpty
            ? nextDrawTime
            : selectedGame.nextDrawTime,
        rawBoardData: updatedBoard,
      );

      Get.to(() => BorletteView(game: boardGameModel));
    } catch (e) {
      debugPrint('Error in playGame: $e');
      // If error, fall back to navigation using whatever data is in board
      final localizationController = Get.find<LocalizationController>();
      final activeLang = localizationController.currentLanguage.value;

      String agentName = board['agent_name_en'] ?? '';
      if (activeLang == 'fr') {
        agentName = board['agent_name_fr'] ?? board['agent_name_en'] ?? '';
      } else if (activeLang == 'ht') {
        agentName = board['agent_name_ht'] ?? board['agent_name_en'] ?? '';
      }

      String drawName = board['draw_session_name_en'] ?? '';
      if (activeLang == 'fr') {
        drawName =
            board['draw_session_name_fr'] ??
            board['draw_session_name_en'] ??
            '';
      } else if (activeLang == 'ht') {
        drawName =
            board['draw_session_name_ht'] ??
            board['draw_session_name_en'] ??
            '';
      }

      String nextDrawTime = board['next_draw_label_en'] ?? '';
      if (activeLang == 'fr') {
        nextDrawTime =
            board['next_draw_label_fr'] ?? board['next_draw_label_en'] ?? '';
      } else if (activeLang == 'ht') {
        nextDrawTime =
            board['next_draw_label_ht'] ?? board['next_draw_label_en'] ?? '';
      }

      final boardGameModel = GameModel(
        id: selectedGame.id,
        name: selectedGame.name,
        payout: selectedGame.payout,
        category: selectedGame.category,
        cardGradient: selectedGame.cardGradient,
        minBet: selectedGame.minBet,
        maxBet: selectedGame.maxBet,
        agentName: agentName,
        drawName: drawName,
        nextDrawTime: nextDrawTime,
        rawBoardData: Map<String, dynamic>.from(board),
      );
      Get.to(() => BorletteView(game: boardGameModel));
    } finally {
      isLoading.value = false;
    }
  }
}
