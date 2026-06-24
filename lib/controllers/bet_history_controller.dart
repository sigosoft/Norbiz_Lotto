import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';
import '../configs/api_config.dart';
import 'localization_controller.dart';

class BetHistoryController extends GetxController {
  var activeFilter = 'All'.obs; // 'All', 'Pending', 'Won', 'Loss'
  var searchQuery = ''.obs;

  var allTickets = <TicketModel>[].obs;
  var filteredTickets = <TicketModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBetHistory();
  }

  Future<void> fetchBetHistory() async {
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

      // Map dynamic filters to query parameters
      String statusParam = '';
      if (activeFilter.value == 'Pending') {
        statusParam = '0';
      } else if (activeFilter.value == 'Won') {
        statusParam = '1';
      } else if (activeFilter.value == 'Loss') {
        statusParam = '2';
      }

      final searchParam = searchQuery.value;

      final String url = '${ApiConfig.baseUrl}${ApiConfig.betHistory}?limit=10&status=$statusParam&search=$searchParam';
      debugPrint('=== FETCH BET HISTORY API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH BET HISTORY RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isLoading.value = false;

      if (response.statusCode == 200 && response.body != null) {
        final resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          return;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'];
          if (data != null && data is Map) {
            final rawBets = data['bets'];
            final List<TicketModel> betsList = [];
            if (rawBets is List) {
              for (var item in rawBets) {
                if (item is Map) {
                  String parsedId = item['ticket_code']?.toString() ?? item['ticket_id']?.toString() ?? item['id']?.toString() ?? '';
                  if (parsedId.isNotEmpty && !parsedId.startsWith('#') && !parsedId.contains('-')) {
                    parsedId = '#$parsedId';
                  }

                  final String lang = Get.isRegistered<LocalizationController>()
                      ? Get.find<LocalizationController>().currentLanguage.value
                      : 'en';

                  String gameName = '';
                  if (lang == 'fr') {
                    gameName = item['game_name_fr']?.toString() ?? '';
                  } else if (lang == 'ht') {
                    gameName = item['game_name_ht']?.toString() ?? '';
                  }
                  if (gameName.isEmpty) {
                    gameName = item['game_name_en']?.toString() ??
                        item['game_name']?.toString() ??
                        item['game']?['name']?.toString() ??
                        '';
                  }

                  final String numbers = item['number_display']?.toString() ??
                      item['number_primary']?.toString() ??
                      item['numbers']?.toString() ??
                      item['number']?.toString() ??
                      '';

                  String displayDate = '';
                  if (lang == 'fr') {
                    displayDate = item['draw_label_fr']?.toString() ?? '';
                  } else if (lang == 'ht') {
                    displayDate = item['draw_label_ht']?.toString() ?? '';
                  } else {
                    displayDate = item['draw_label_en']?.toString() ?? '';
                  }
                  if (displayDate.isEmpty) {
                    final rawDate = item['created_at']?.toString() ?? item['date']?.toString() ?? '';
                    if (rawDate.isNotEmpty) {
                      try {
                        final parsed = DateTime.parse(rawDate);
                        displayDate = DateFormat('MMM dd, yyyy • h:mm a').format(parsed.toLocal()).toUpperCase();
                      } catch (_) {
                        displayDate = rawDate;
                      }
                    }
                  }

                  final double betAmount = double.tryParse(item['bet_amount']?.toString() ?? item['amount']?.toString() ?? '0') ?? 0.0;
                  final double? winAmount = item['win_amount'] != null ? double.tryParse(item['win_amount'].toString()) : null;

                  TicketStatus ticketStatus = TicketStatus.pending;
                  final statusStr = item['status']?.toString().toLowerCase() ?? '';
                  if (statusStr == '1' || statusStr == 'won' || statusStr == 'win') {
                    ticketStatus = TicketStatus.won;
                  } else if (statusStr == '2' || statusStr == 'lost' || statusStr == 'loss') {
                    ticketStatus = TicketStatus.lost;
                  }

                  final String currency = item['currency']?.toString() ?? '';

                  String statusLabel = '';
                  if (lang == 'fr') {
                    statusLabel = item['status_label_fr']?.toString() ?? '';
                  } else if (lang == 'ht') {
                    statusLabel = item['status_label_ht']?.toString() ?? '';
                  }
                  if (statusLabel.isEmpty) {
                    statusLabel = item['status_label_en']?.toString() ?? '';
                  }

                  betsList.add(
                    TicketModel(
                      id: parsedId,
                      gameName: gameName,
                      numbers: numbers,
                      date: displayDate,
                      betAmount: betAmount,
                      winAmount: winAmount,
                      status: ticketStatus,
                      currency: currency,
                      statusLabel: statusLabel,
                    ),
                  );
                }
              }
            }
            allTickets.value = betsList;
            applyFilters();
          }
        }
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error fetching bet history: $e');
    }
  }

  void changeFilter(String filter) {
    activeFilter.value = filter;
    fetchBetHistory();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    fetchBetHistory();
  }

  void applyFilters() {
    List<TicketModel> results = allTickets;

    // Filter by tab (client-side fallback/filtering matching existing logic)
    if (activeFilter.value == 'Pending') {
      results = results.where((t) => t.status == TicketStatus.pending).toList();
    } else if (activeFilter.value == 'Won') {
      results = results.where((t) => t.status == TicketStatus.won).toList();
    } else if (activeFilter.value == 'Loss') {
      results = results.where((t) => t.status == TicketStatus.lost).toList();
    }

    // Filter by search (client-side fallback/filtering matching existing logic)
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
