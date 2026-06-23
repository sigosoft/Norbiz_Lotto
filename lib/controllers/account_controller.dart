import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import 'auth_controller.dart';
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

  // Bank Accounts Loading
  var isBankLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMockData();
    try {
      Get.find<AuthController>().fetchProfile();
    } catch (_) {}
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
  void addBankAccount(String holder, String number, String bank) {
    String masked = number.length > 4
        ? '${'*' * (number.length - 4)} ${number.substring(number.length - 4)}'
        : number;
    savedAccounts.add(
      BankAccountModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        accountHolder: holder,
        accountNumber: masked,
        bankName: bank,
      ),
    );
    Get.back();
    showToast('Bank account added successfully.'.tr, title: 'Success');
  }

  void deleteBankAccount(String id) {
    savedAccounts.removeWhere((acc) => acc.id == id);
    showToast('Bank account removed.'.tr, title: 'Deleted');
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
  void depositFunds(double amount) {
    final authController = Get.find<AuthController>();
    authController.userWalletBalance.value += amount;

    // Add transaction record
    allTransactions.insert(
      0,
      TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.deposit,
        title: 'Bank Deposit',
        date: 'MAR 11, 2026 • 2:00 PM',
        amount: amount,
        status: TransactionStatus.completed,
      ),
    );
    filterTransactions();

    showToast(
      'Amount of \$${amount.toStringAsFixed(2)} has been added to your wallet.'
          .tr,
      title: 'Deposit Successful',
    );
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
          final rawData = dataMap['data'];
          final List<BankAccountModel> accountsList = [];
          if (rawData is List) {
            for (var item in rawData) {
              if (item is Map) {
                accountsList.add(
                  BankAccountModel(
                    id: item['id']?.toString() ?? '',
                    accountHolder: item['account_holder']?.toString() ??
                        item['accountHolder']?.toString() ??
                        '',
                    accountNumber: item['account_number']?.toString() ??
                        item['accountNumber']?.toString() ??
                        '',
                    bankName: item['bank_name']?.toString() ??
                        item['bankName']?.toString() ??
                        '',
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
}
