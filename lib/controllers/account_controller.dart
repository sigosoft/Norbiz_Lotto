import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import 'auth_controller.dart';
import 'localization_controller.dart';
import 'connectivity_controller.dart';
import '../configs/toast.dart';
import '../configs/api_config.dart';

class AccountController extends GetxController {
  // Bank Accounts
  var savedAccounts = <BankAccountModel>[].obs;

  // Transactions
  var activeTxFilter = 'All'.obs; // 'All', 'Deposits', 'Withdrawals'
  var allTransactions = <TransactionModel>[].obs;
  var filteredTransactions = <TransactionModel>[].obs;

  // Privacy Policy
  var isPolicyLoading = false.obs;
  var policyTitleEn = ''.obs;
  var policyTitleFr = ''.obs;
  var policyTitleHt = ''.obs;
  var policyContentEn = ''.obs;
  var policyContentFr = ''.obs;
  var policyContentHt = ''.obs;

  // Terms & Conditions
  var isTermsLoading = false.obs;
  var termsTitleEn = ''.obs;
  var termsTitleFr = ''.obs;
  var termsTitleHt = ''.obs;
  var termsContentEn = ''.obs;
  var termsContentFr = ''.obs;
  var termsContentHt = ''.obs;

  // Anti-Fraud Policy
  var isFraudLoading = false.obs;
  var fraudTitleEn = ''.obs;
  var fraudTitleFr = ''.obs;
  var fraudTitleHt = ''.obs;
  var fraudContentEn = ''.obs;
  var fraudContentFr = ''.obs;
  var fraudContentHt = ''.obs;

  // Under-18 Protection Policy
  var isUnder18Loading = false.obs;
  var under18TitleEn = ''.obs;
  var under18TitleFr = ''.obs;
  var under18TitleHt = ''.obs;
  var under18ContentEn = ''.obs;
  var under18ContentFr = ''.obs;
  var under18ContentHt = ''.obs;

  // General Settings
  var isGeneralLoading = false.obs;
  var facebookUrl = ''.obs;
  var twitterUrl = ''.obs;
  var instagramUrl = ''.obs;
  var whatsappUrl = ''.obs;
  var whatsappNumber = ''.obs;
  var contactEmail = ''.obs;
  var appAddress = ''.obs;
  var workingHoursStart = ''.obs;
  var workingHoursEnd = ''.obs;
  var androidVersion = ''.obs;
  var iosVersion = ''.obs;
  var isAndroidForceUpdate = false.obs;
  var isIosForceUpdate = false.obs;
  var isAndroidMaintenance = false.obs;
  var isIosMaintenance = false.obs;

  // Bank Accounts Loading
  var isBankLoading = false.obs;

  // Transactions Loading
  var isTransactionsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('=== AccountController onInit called ===');
    loadMockData();
    try {
      final authController = Get.find<AuthController>();
      authController.fetchProfileAndWallet();
      fetchGeneralSettings();
    } catch (e, stack) {
      debugPrint('Error on init AccountController: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  void loadMockData() {
    // Bank accounts
    savedAccounts.value = [];

    // Transactions list
    allTransactions.value = [
      TransactionModel(
        id: 'tx1',
        type: TransactionType.deposit,
        title: 'Bank Deposit',
        date: 'MAR 11, 2024 • 2:00 PM',
        amount: 200.0,
        status: TransactionStatus.completed,
      ),
      TransactionModel(
        id: 'tx2',
        type: TransactionType.withdrawal,
        title: 'Withdraw to Bank',
        date: 'MAR 11, 2024 • 2:00 PM',
        amount: 183.0,
        status: TransactionStatus.completed,
      ),
      TransactionModel(
        id: 'tx3',
        type: TransactionType.withdrawal,
        title: 'Withdraw to Bank',
        date: 'MAR 11, 2024 • 2:00 PM',
        amount: 160.0,
        status: TransactionStatus.processing,
      ),
    ];
    filterTransactions();
  }

  // Add Bank Account
  Future<bool> addBankAccount({
    required String holder,
    required String number,
    required String bank,
    String swift = '',
    String currency = 'USD',
  }) async {
    isBankLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.addBankAccount}';

      final Map<String, String> body = {
        'account_holder_name': holder,
        'bank_name': bank,
        'account_number': number,
        'branch_name': swift.isEmpty ? "Main Branch" : swift,
        'account_type': '2', // default type
        'is_default': '1', // default value
        'currency': currency,
      };

      debugPrint('=== ADD BANK ACCOUNT API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await connect.post(
        url,
        FormData(body),
        headers: headers,
      );

      debugPrint('=== ADD BANK ACCOUNT RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isBankLoading.value = false;

      if (response.body != null) {
        final resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          showToast('Unexpected response format.'.tr, title: 'Error');
          return false;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          // Store currency locally keyed by the new bank account ID
          try {
            final newAccountData = dataMap['data'];
            String? newId;
            if (newAccountData is Map) {
              final accInfo = newAccountData['bank_account'] ?? newAccountData;
              if (accInfo is Map) {
                newId = accInfo['id']?.toString();
              }
            }
            if (newId != null && newId.isNotEmpty) {
              await prefs.setString('bank_currency_$newId', currency);
            }
          } catch (e) {
            debugPrint('Error saving currency locally: $e');
          }

          Get.back();
          showToast('Bank account added successfully.'.tr, title: 'Success');
          fetchBankAccounts();
          return true;
        } else {
          final rawMsg = dataMap['message'];
          String msg = _parseErrorMessage(rawMsg);
          showToast(msg, title: 'Error');
          return false;
        }
      } else {
        showToast(
          'Failed to add bank account. Please try again.'.tr,
          title: 'Error',
        );
        return false;
      }
    } catch (e) {
      isBankLoading.value = false;
      debugPrint('Error adding bank account: $e');
      showToast('An error occurred. Please try again.'.tr, title: 'Error');
      return false;
    }
  }

  String _parseErrorMessage(dynamic messageObj) {
    if (messageObj == null) return 'An error occurred. Please try again.';
    if (messageObj is String) return messageObj;
    if (messageObj is List) {
      if (messageObj.isEmpty) return 'An error occurred. Please try again.';
      return messageObj.map((e) => _parseErrorMessage(e)).join('\n');
    }
    if (messageObj is Map) {
      String lang = 'en';
      try {
        lang = Get.find<LocalizationController>().currentLanguage.value;
      } catch (_) {}

      // Try language specific keys ending with _en, _fr, _ht
      final suffix = '_$lang';
      for (var key in messageObj.keys) {
        if (key.toString().endsWith(suffix)) {
          final val = messageObj[key];
          if (val != null) {
            return _parseErrorMessage(val);
          }
        }
      }

      // Try direct fields if any
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

  Future<bool> deleteBankAccount(String id) async {
    isBankLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.deleteBankAccount}';

      final Map<String, String> body = {'id': id, 'bank_account_id': id};

      debugPrint('=== DELETE BANK ACCOUNT API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await connect.post(
        url,
        FormData(body),
        headers: headers,
      );

      debugPrint('=== DELETE BANK ACCOUNT RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isBankLoading.value = false;

      if (response.body != null) {
        final resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          showToast('Unexpected response format.'.tr, title: 'Error');
          return false;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final rawMsg = dataMap['message'];
          String msg = _parseErrorMessage(rawMsg);
          if (msg.isEmpty || msg.contains('An error occurred')) {
            msg = 'Bank account removed.';
          }
          showToast(msg.tr, title: 'Deleted');
          fetchBankAccounts();
          return true;
        } else {
          final rawMsg = dataMap['message'];
          String msg = _parseErrorMessage(rawMsg);
          showToast(msg, title: 'Error');
          return false;
        }
      } else {
        showToast(
          'Failed to remove bank account. Please try again.'.tr,
          title: 'Error',
        );
        return false;
      }
    } catch (e) {
      isBankLoading.value = false;
      debugPrint('Error deleting bank account: $e');
      showToast('An error occurred. Please try again.'.tr, title: 'Error');
      return false;
    }
  }

  Future<bool> updateBankAccount({
    required String id,
    required String holder,
    required String number,
    required String bank,
    String swift = '',
    String currency = 'USD',
  }) async {
    isBankLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.updateBankAccount}';

      final Map<String, String> body = {
        'id': id,
        'account_holder_name': holder,
        'bank_name': bank,
        'account_number': number,
        'branch_name': swift.isEmpty ? "Main Branch" : swift,
        'account_type': '2', // default type
        'is_default': '1', // default value
        'currency': currency,
      };

      debugPrint('=== UPDATE BANK ACCOUNT API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await connect.post(
        url,
        FormData(body),
        headers: headers,
      );

      debugPrint('=== UPDATE BANK ACCOUNT RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isBankLoading.value = false;

      if (response.body != null) {
        final resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          showToast('Unexpected response format.'.tr, title: 'Error');
          return false;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          try {
            await prefs.setString('bank_currency_$id', currency);
          } catch (e) {
            debugPrint('Error saving currency locally during update: $e');
          }

          Get.back();
          showToast('Bank account updated successfully.'.tr, title: 'Success');
          fetchBankAccounts();
          return true;
        } else {
          final rawMsg = dataMap['message'];
          String msg = _parseErrorMessage(rawMsg);
          showToast(msg, title: 'Error');
          return false;
        }
      } else {
        showToast(
          'Failed to update bank account. Please try again.'.tr,
          title: 'Error',
        );
        return false;
      }
    } catch (e) {
      isBankLoading.value = false;
      debugPrint('Error updating bank account: $e');
      showToast('An error occurred. Please try again.'.tr, title: 'Error');
      return false;
    }
  }

  // Transaction Filters
  void changeTxFilter(String filter) {
    activeTxFilter.value = filter;
    filterTransactions();
  }

  void filterTransactions() {
    if (activeTxFilter.value == 'Deposits') {
      filteredTransactions.value = allTransactions
          .where((tx) => tx.type == TransactionType.deposit)
          .toList();
    } else if (activeTxFilter.value == 'Withdrawals') {
      filteredTransactions.value = allTransactions
          .where((tx) => tx.type == TransactionType.withdrawal)
          .toList();
    } else {
      filteredTransactions.value = allTransactions;
    }
  }

  // Wallet deposits/withdrawals simulation
  // Wallet deposits/withdrawals API integration
  Future<bool> depositFunds(double amount) async {
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
          '${ApiConfig.baseUrl}${ApiConfig.walletTopup}?amount=$amount';

      debugPrint('=== DEPOSIT FUNDS API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.post(
        url,
        FormData({'amount': amount.toString()}),
        headers: headers,
      );

      debugPrint('=== DEPOSIT FUNDS RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        final resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          showToast('Failed to parse response.'.tr, title: 'Error'.tr);
          return false;
        }

        if (dataMap['status'] == 'true' ||
            dataMap['status'] == true ||
            dataMap['status'] == 'success') {
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};
          final wallet = data['wallet'] != null
              ? Map<String, dynamic>.from(data['wallet'])
              : <String, dynamic>{};

          if (wallet.isNotEmpty) {
            final balance =
                double.tryParse(wallet['balance']?.toString() ?? '') ?? 0.0;
            final authController = Get.find<AuthController>();
            authController.userWalletBalance.value = balance;
            debugPrint('Wallet balance updated after topup: $balance');
          }

          // Fetch updated transactions list in the background
          fetchTransactions().catchError((e) {
            debugPrint('Error fetching transactions: $e');
          });

          Get.back(); // Navigate back to the previous screen first
          showToast(
            dataMap['message'] ?? 'Topup successful.'.tr,
            title: 'Success'.tr,
          );
          return true;
        } else {
          showToast(
            dataMap['message'] ?? 'Deposit failed.'.tr,
            title: 'Error'.tr,
          );
          return false;
        }
      } else {
        showToast('Failed to connect to the server.'.tr, title: 'Error'.tr);
        return false;
      }
    } catch (e) {
      debugPrint('Error depositing funds: $e');
      showToast('An error occurred. Please try again.'.tr, title: 'Error'.tr);
      return false;
    }
  }

  bool withdrawFunds(double amount) {
    final authController = Get.find<AuthController>();
    authController.userWalletBalance.value -= amount;

    // Add transaction record
    allTransactions.insert(
      0,
      TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.withdrawal,
        title: 'Withdraw to Bank',
        date: 'MAR 11, 2026 • 2:00 PM',
        amount: amount,
        status: TransactionStatus.processing,
      ),
    );
    filterTransactions();

    showToast(
      'Amount of \$${amount.toStringAsFixed(2)} withdrawal is processing.'.tr,
      title: 'Withdrawal Processing',
    );
    return true;
  }

  Future<void> fetchPrivacyPolicy() async {
    isPolicyLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.privacyPolicy}';
      debugPrint('=== FETCH PRIVACY POLICY API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH PRIVACY POLICY RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isPolicyLoading.value = false;

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
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};

          policyTitleEn.value = data['title_en']?.toString() ?? '';
          policyTitleFr.value = data['title_fr']?.toString() ?? '';
          policyTitleHt.value = data['title_ht']?.toString() ?? '';
          policyContentEn.value = data['content_en']?.toString() ?? '';
          policyContentFr.value = data['content_fr']?.toString() ?? '';
          policyContentHt.value = data['content_ht']?.toString() ?? '';
        }
      }
    } catch (e) {
      isPolicyLoading.value = false;
      debugPrint('Error fetching privacy policy: $e');
    }
  }

  Future<void> fetchTermsAndConditions() async {
    isTermsLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.termsAndConditions}';
      debugPrint('=== FETCH TERMS & CONDITIONS API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH TERMS & CONDITIONS RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isTermsLoading.value = false;

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
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};

          termsTitleEn.value = data['title_en']?.toString() ?? '';
          termsTitleFr.value = data['title_fr']?.toString() ?? '';
          termsTitleHt.value = data['title_ht']?.toString() ?? '';
          termsContentEn.value = data['content_en']?.toString() ?? '';
          termsContentFr.value = data['content_fr']?.toString() ?? '';
          termsContentHt.value = data['content_ht']?.toString() ?? '';
        }
      }
    } catch (e) {
      isTermsLoading.value = false;
      debugPrint('Error fetching terms and conditions: $e');
    }
  }

  Future<void> fetchAntiFraudPolicy() async {
    isFraudLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.antiFraudPolicy}';
      debugPrint('=== FETCH ANTI-FRAUD POLICY API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH ANTI-FRAUD POLICY RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isFraudLoading.value = false;

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
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};

          fraudTitleEn.value = data['title_en']?.toString() ?? '';
          fraudTitleFr.value = data['title_fr']?.toString() ?? '';
          fraudTitleHt.value = data['title_ht']?.toString() ?? '';
          fraudContentEn.value = data['content_en']?.toString() ?? '';
          fraudContentFr.value = data['content_fr']?.toString() ?? '';
          fraudContentHt.value = data['content_ht']?.toString() ?? '';
        }
      }
    } catch (e) {
      isFraudLoading.value = false;
      debugPrint('Error fetching anti-fraud policy: $e');
    }
  }

  Future<void> fetchUnder18ProtectionPolicy() async {
    isUnder18Loading.value = true;
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
          '${ApiConfig.baseUrl}${ApiConfig.under18ProtectionPolicy}';
      debugPrint('=== FETCH UNDER-18 PROTECTION POLICY API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH UNDER-18 PROTECTION POLICY RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isUnder18Loading.value = false;

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
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};

          under18TitleEn.value = data['title_en']?.toString() ?? '';
          under18TitleFr.value = data['title_fr']?.toString() ?? '';
          under18TitleHt.value = data['title_ht']?.toString() ?? '';
          under18ContentEn.value = data['content_en']?.toString() ?? '';
          under18ContentFr.value = data['content_fr']?.toString() ?? '';
          under18ContentHt.value = data['content_ht']?.toString() ?? '';
        }
      }
    } catch (e) {
      isUnder18Loading.value = false;
      debugPrint('Error fetching under-18 protection policy: $e');
    }
  }

  Future<void> fetchBankAccounts() async {
    isBankLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.bankAccounts}';
      debugPrint('=== FETCH BANK ACCOUNTS API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH BANK ACCOUNTS RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isBankLoading.value = false;

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
          dynamic rawData = dataMap['data'];
          if (rawData is Map && rawData.containsKey('bank_accounts')) {
            rawData = rawData['bank_accounts'];
          }
          final List<BankAccountModel> accountsList = [];
          if (rawData is List) {
            for (var item in rawData) {
              if (item is Map) {
                final String accId = item['id']?.toString() ?? '';
                final String localCurrency =
                    prefs.getString('bank_currency_$accId') ??
                    item['currency']?.toString() ??
                    item['currency_code']?.toString() ??
                    'USD';
                accountsList.add(
                  BankAccountModel(
                    id: accId,
                    accountHolder:
                        item['account_holder_name']?.toString() ??
                        item['account_holder']?.toString() ??
                        item['accountHolder']?.toString() ??
                        '',
                    accountNumber:
                        item['account_number_masked']?.toString() ??
                        item['account_number']?.toString() ??
                        item['accountNumber']?.toString() ??
                        '',
                    bankName:
                        item['bank_name']?.toString() ??
                        item['bankName']?.toString() ??
                        '',
                    branchName:
                        item['branch_name']?.toString() ??
                        item['branchName']?.toString() ??
                        '',
                    currency: localCurrency,
                  ),
                );
              }
            }
          }
          savedAccounts.value = accountsList;
        }
      }
    } catch (e) {
      isBankLoading.value = false;
      debugPrint('Error fetching bank accounts: $e');
    }
  }

  Future<void> fetchTransactions({int limit = 10}) async {
    isTransactionsLoading.value = true;
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
          '${ApiConfig.baseUrl}${ApiConfig.walletTransactions}?limit=$limit';
      debugPrint('=== FETCH TRANSACTIONS API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH TRANSACTIONS RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isTransactionsLoading.value = false;

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
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};
          final transactionsList = data['transactions'] != null
              ? List<dynamic>.from(data['transactions'])
              : [];

          final List<TransactionModel> loadedTx = [];
          for (var item in transactionsList) {
            if (item is Map) {
              final id =
                  item['id']?.toString() ??
                  item['transaction_id']?.toString() ??
                  '';

              // Map type string to enum
              final typeStr =
                  (item['type'] ?? item['transaction_type'] ?? 'deposit')
                      .toString()
                      .toLowerCase();
              final TransactionType type =
                  typeStr.contains('withdrawal') || typeStr.contains('debit')
                  ? TransactionType.withdrawal
                  : TransactionType.deposit;

              // Title mapping
              final title =
                  item['title_en'] ??
                  item['title'] ??
                  item['remark'] ??
                  (type == TransactionType.deposit ? 'Deposit' : 'Withdrawal');

              // Date mapping
              final date = item['created_at'] ?? item['date'] ?? '';

              // Amount
              final amount =
                  double.tryParse(item['amount']?.toString() ?? '0.0') ?? 0.0;

              // Status mapping
              final statusStr = (item['status'] ?? 'completed')
                  .toString()
                  .toLowerCase();
              final TransactionStatus status =
                  statusStr.contains('process') || statusStr.contains('pending')
                  ? TransactionStatus.processing
                  : (statusStr.contains('fail') || statusStr.contains('reject')
                        ? TransactionStatus.failed
                        : TransactionStatus.completed);

              loadedTx.add(
                TransactionModel(
                  id: id,
                  type: type,
                  title: title.toString(),
                  date: date.toString(),
                  amount: amount,
                  status: status,
                ),
              );
            }
          }
          allTransactions.value = loadedTx;
          filterTransactions();
        }
      }
    } catch (e, stackTrace) {
      isTransactionsLoading.value = false;
      debugPrint('Error fetching transactions: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> fetchGeneralSettings() async {
    isGeneralLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.general}';
      debugPrint('=== FETCH GENERAL SETTINGS API CALL ===');
      debugPrint('URL: $url');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH GENERAL SETTINGS RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isGeneralLoading.value = false;

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
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};

          final general = data['general'] != null
              ? Map<String, dynamic>.from(data['general'])
              : <String, dynamic>{};

          facebookUrl.value = general['facebook']?.toString() ?? '';
          twitterUrl.value = general['twitter']?.toString() ?? '';
          instagramUrl.value = general['instagram']?.toString() ?? '';
          whatsappUrl.value = general['whatsapp']?.toString() ?? '';
          whatsappNumber.value = general['whatsapp_number']?.toString() ?? '';
          contactEmail.value = general['email']?.toString() ?? '';
          appAddress.value = general['address']?.toString() ?? '';
          workingHoursStart.value =
              general['working_hours_start']?.toString() ?? '';
          workingHoursEnd.value =
              general['working_hours_end']?.toString() ?? '';

          androidVersion.value = general['version_android']?.toString() ?? '';
          iosVersion.value = general['version_ios']?.toString() ?? '';
          isAndroidForceUpdate.value =
              (general['force_update_android'] == 1 ||
              general['force_update_android'] == '1');
          isIosForceUpdate.value =
              (general['force_update_ios'] == 1 ||
              general['force_update_ios'] == '1');
          isAndroidMaintenance.value =
              (general['maintenance_android'] == 1 ||
              general['maintenance_android'] == '1');
          isIosMaintenance.value =
              (general['maintenance_ios'] == 1 ||
              general['maintenance_ios'] == '1');

          // Sync with connectivity controller
          try {
            final connectivityController = Get.find<ConnectivityController>();
            bool isMaintenanceActive = false;
            bool isUpdateRequiredActive = false;
            if (Platform.isAndroid) {
              isMaintenanceActive = isAndroidMaintenance.value;
              isUpdateRequiredActive = isAndroidForceUpdate.value;
            } else if (Platform.isIOS) {
              isMaintenanceActive = isIosMaintenance.value;
              isUpdateRequiredActive = isIosForceUpdate.value;
            }
            connectivityController.isMaintenance.value = isMaintenanceActive;
            connectivityController.isUpdateRequired.value =
                isUpdateRequiredActive;
          } catch (e) {
            debugPrint('Error syncing connectivity controller: $e');
          }
        }
      }
    } catch (e) {
      isGeneralLoading.value = false;
      debugPrint('Error fetching general settings: $e');
    }
  }

  Future<void> launchURL(String urlString) async {
    if (urlString.isEmpty) return;
    try {
      final Uri url = Uri.parse(urlString);
      // Try to launch external application directly to support Android 11+ query limitations
      bool launched = await launcher.launchUrl(
        url,
        mode: launcher.LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint(
          'Could not launch $urlString via externalApplication, trying fallback...',
        );
        await launcher.launchUrl(url);
      }
    } catch (e) {
      debugPrint('Error launching url $urlString: $e');
      try {
        final Uri url = Uri.parse(urlString);
        await launcher.launchUrl(url);
      } catch (err) {
        debugPrint('Fallback launch url failed: $err');
      }
    }
  }

  Future<void> launchWhatsApp(String number, String fallbackUrl) async {
    if (number.isNotEmpty) {
      final String formattedNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
      final String waUrl = "https://wa.me/$formattedNumber";
      await launchURL(waUrl);
    } else if (fallbackUrl.isNotEmpty) {
      await launchURL(fallbackUrl);
    } else {
      await launchURL("https://wa.me/11234567800");
    }
  }

  Future<void> checkForUpdateManual() async {
    showToast('Checking for updates...'.tr, title: 'System Update');
    await fetchGeneralSettings();

    String apiVersion = '1.0.0';
    if (Platform.isAndroid) {
      apiVersion = androidVersion.value;
    } else if (Platform.isIOS) {
      apiVersion = iosVersion.value;
    }

    const String currentVersion = '2.8.1';
    bool hasUpdate = false;
    try {
      if (apiVersion.isNotEmpty) {
        final apiParts = apiVersion
            .split('.')
            .map((e) => int.tryParse(e) ?? 0)
            .toList();
        final currParts = currentVersion
            .split('.')
            .map((e) => int.tryParse(e) ?? 0)
            .toList();

        for (int i = 0; i < apiParts.length; i++) {
          int currVal = i < currParts.length ? currParts[i] : 0;
          if (apiParts[i] > currVal) {
            hasUpdate = true;
            break;
          } else if (apiParts[i] < currVal) {
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing version: $e');
    }

    if (hasUpdate) {
      Get.snackbar(
        'Update Available'.tr,
        'A new version (v$apiVersion) is available. Please update.'.tr,
        backgroundColor: Colors.white.withOpacity(0.9),
        colorText: const Color(0xFF0D319C),
        duration: const Duration(seconds: 4),
      );
    } else {
      Get.snackbar(
        'System Update'.tr,
        'You are running the latest version.'.tr,
        backgroundColor: Colors.white.withOpacity(0.9),
        colorText: const Color(0xFF0D319C),
      );
    }
  }

  Future<void> fetchHelpCenter() async {
    isGeneralLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.helpCenter}';
      debugPrint('=== FETCH HELP CENTER API CALL ===');
      debugPrint('URL: $url');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH HELP CENTER RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isGeneralLoading.value = false;

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
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};

          final helpCenter = data['help_center'] != null
              ? Map<String, dynamic>.from(data['help_center'])
              : <String, dynamic>{};

          if (helpCenter.isNotEmpty) {
            final whatsapp = helpCenter['whatsapp'] != null
                ? Map<String, dynamic>.from(helpCenter['whatsapp'])
                : <String, dynamic>{};

            whatsappNumber.value = whatsapp['number']?.toString() ?? '';
            whatsappUrl.value = whatsapp['link']?.toString() ?? '';
            contactEmail.value = helpCenter['email']?.toString() ?? '';
            appAddress.value = helpCenter['address']?.toString() ?? '';

            final businessHours = helpCenter['business_hours'] != null
                ? Map<String, dynamic>.from(helpCenter['business_hours'])
                : <String, dynamic>{};

            workingHoursStart.value = businessHours['start']?.toString() ?? '';
            workingHoursEnd.value = businessHours['end']?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      isGeneralLoading.value = false;
      debugPrint('Error fetching help center: $e');
    }
  }
}
