import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:norbiz_loto/controllers/localization_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';
import '../configs/api_config.dart';
import '../configs/toast.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
  var cartTickets = <TicketModel>[].obs;
  var isLoading = false.obs;
  var apiSubtotal = 0.0.obs;
  var apiServiceFee = 0.0.obs;
  var apiTotal = 0.0.obs;
  var apiTotalTickets = 0.obs;

  @override
  void onInit() {
    super.onInit();
    addTicket('Borlette FL', '99', 10.0);
  }

  double get subtotal => apiSubtotal.value > 0.0
      ? apiSubtotal.value
      : cartTickets.fold(0.0, (sum, ticket) => sum + ticket.betAmount);

  double get serviceFee => apiServiceFee.value > 0.0
      ? apiServiceFee.value
      : (cartTickets.isEmpty ? 0.0 : 1.00); // Flat fee fallback

  double get total =>
      apiTotal.value > 0.0 ? apiTotal.value : (subtotal + serviceFee);

  Future<void> fetchCart() async {
    if (isLoading.value) return;
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

      final url = '${ApiConfig.baseUrl}${ApiConfig.cart}';

      debugPrint('=== FETCH CART API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Token: $token');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH CART RESPONSE ===');
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

          // Update summary values from API
          final summary = data['summary'] != null
              ? Map<String, dynamic>.from(data['summary'])
              : {};
          apiSubtotal.value =
              double.tryParse(summary['subtotal']?.toString() ?? '0.0') ?? 0.0;
          apiServiceFee.value =
              double.tryParse(summary['service_fee']?.toString() ?? '0.0') ??
              0.0;
          apiTotal.value =
              double.tryParse(summary['total_amount']?.toString() ?? '0.0') ??
              0.0;
          apiTotalTickets.value =
              int.tryParse(summary['total_tickets']?.toString() ?? '0') ?? 0;

          // Update wallet balance in AuthController from API
          final wallet = data['wallet'] != null
              ? Map<String, dynamic>.from(data['wallet'])
              : {};
          if (wallet.isNotEmpty) {
            final balance =
                double.tryParse(wallet['balance']?.toString() ?? '0.0') ?? 0.0;
            final authController = Get.find<AuthController>();
            authController.userWalletBalance.value = balance;
          }

          // Parse cart lines from API
          final lines = data['lines'] != null
              ? List<dynamic>.from(data['lines'])
              : [];
          final List<TicketModel> loadedTickets = [];
          for (var line in lines) {
            final lineMap = Map<String, dynamic>.from(line);

            // Extract details with flexible lookups
            final id =
                lineMap['cart_item_id']?.toString() ??
                lineMap['id']?.toString() ??
                '';

            // Extract game name
            final localController = Get.isRegistered<LocalizationController>()
                ? Get.find<LocalizationController>()
                : null;
            final lang = localController?.currentLanguage.value ?? 'en';
            String gameName = 'Unknown Game';
            if (lineMap['game'] != null) {
              final gameData = Map<String, dynamic>.from(lineMap['game']);
              gameName =
                  gameData['name_$lang'] ??
                  gameData['name_en'] ??
                  gameData['name'] ??
                  gameName;
            } else {
              gameName =
                  lineMap['game_name_$lang']?.toString() ??
                  lineMap['game_name_en']?.toString() ??
                  lineMap['game_name']?.toString() ??
                  gameName;
            }

            final numPrimary = lineMap['number_primary']?.toString() ?? '';
            final numSecondary = lineMap['number_secondary']?.toString() ?? '';
            String numbers = numPrimary + numSecondary;
            if (numbers.isEmpty) {
              numbers =
                  (lineMap['numbers'] ??
                          lineMap['number'] ??
                          lineMap['bet_number'] ??
                          '')
                      .toString();
            }

            final betAmount =
                double.tryParse(
                  lineMap['bet_amount']?.toString() ??
                      lineMap['amount']?.toString() ??
                      '0.0',
                ) ??
                0.0;
            final date =
                lineMap['draw_session_name_en']?.toString() ??
                lineMap['official_draw_at']?.toString() ??
                lineMap['date']?.toString() ??
                lineMap['created_at']?.toString() ??
                'MAR 11, 2026 • 2:00 PM';

            loadedTickets.add(
              TicketModel(
                id: id,
                gameName: gameName,
                numbers: numbers,
                date: date,
                betAmount: betAmount,
                status: TicketStatus.pending,
              ),
            );
          }

          cartTickets.value = loadedTickets;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching cart data: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addToCart({
    required int drawId,
    required int gameTypeId,
    required String numberPrimary,
    required String numberSecondary,
    required double betAmount,
  }) async {
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

      final Map<String, dynamic> body = {
        'draw_id': drawId.toString(),
        'game_type_id': gameTypeId.toString(),
        'number_primary': numberPrimary,
        'number_secondary': numberSecondary,
        'bet_amount': betAmount.toString(),
      };

      final url = '${ApiConfig.baseUrl}${ApiConfig.cartAdd}';
      debugPrint('=== ADD TO CART API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Token: $token');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await connect.post(
        url,
        FormData(body),
        headers: headers,
      );

      debugPrint('=== ADD TO CART RESPONSE ===');
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
          return false;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          // Refresh the cart so local variables and counts match backend
          await fetchCart();
          return true;
        } else {
          final errMsg = _parseErrorMessage(dataMap['message']);
          showToast(errMsg, title: 'Error');
          return false;
        }
      } else {
        final dynamic resData = response.body;
        String errMsg = 'Server error. Please try again.';
        if (resData != null && resData is Map && resData['message'] != null) {
          errMsg = _parseErrorMessage(resData['message']);
        }
        showToast(errMsg, title: 'Error');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      showToast('Connection error: $e', title: 'Error');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void addTicket(String gameName, String numbers, double amount) {
    String id =
        '#NZL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Check if ticket already exists in cart, then update or add new
    cartTickets.add(
      TicketModel(
        id: id,
        gameName: gameName,
        numbers: numbers,
        date: 'MAR 11, 2026 • 2:00 PM', // Match Figma mock dates
        betAmount: amount,
        status: TicketStatus.pending,
      ),
    );
  }

  void removeTicket(int index) {
    if (index >= 0 && index < cartTickets.length) {
      cartTickets.removeAt(index);
    }
  }

  void clearCart() {
    cartTickets.clear();
  }

  bool checkout() {
    if (cartTickets.isEmpty) return false;

    // Deduct amount
    final authController = Get.find<AuthController>();
    authController.userWalletBalance.value -= total;

    return true;
  }

  String _parseErrorMessage(dynamic messageObj) {
    if (messageObj == null) return 'An error occurred. Please try again.';
    if (messageObj is String) return messageObj;
    if (messageObj is List) {
      if (messageObj.isEmpty) return 'An error occurred. Please try again.';
      return messageObj.map((e) => _parseErrorMessage(e)).join('\n');
    }
    if (messageObj is Map) {
      final msgEn = messageObj['message_en'];
      if (msgEn != null) return _parseErrorMessage(msgEn);
      final msgFr = messageObj['message_fr'];
      if (msgFr != null) return _parseErrorMessage(msgFr);
      final msgHt = messageObj['message_ht'];
      if (msgHt != null) return _parseErrorMessage(msgHt);

      // Fallback
      if (messageObj.isNotEmpty) {
        return _parseErrorMessage(messageObj.values.first);
      }
    }
    return messageObj.toString();
  }
}
