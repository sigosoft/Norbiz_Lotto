import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import 'auth_controller.dart';
import '../configs/toast.dart';

class AccountController extends GetxController {
  // Bank Accounts
  var savedAccounts = <BankAccountModel>[].obs;

  // Transactions
  var activeTxFilter = 'All'.obs; // 'All', 'Deposits', 'Withdrawls'
  var allTransactions = <TransactionModel>[].obs;
  var filteredTransactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  void loadMockData() {
    // Bank accounts
    savedAccounts.value = [
      BankAccountModel(
        id: '1',
        accountHolder: 'Alex Thompson',
        accountNumber: '******** 4589',
        bankName: 'Sogebank',
      ),
    ];

    // Transactions list
    allTransactions.value = [
      TransactionModel(
        id: 'tx1',
        type: TransactionType.deposit,
        title: 'Bank Deposit',
        date: 'MAR 11, 2026 • 2:00 PM',
        amount: 200.0,
        status: TransactionStatus.completed,
      ),
      TransactionModel(
        id: 'tx2',
        type: TransactionType.withdrawal,
        title: 'Withdraw to Bank',
        date: 'MAR 11, 2026 • 2:00 PM',
        amount: 150.0,
        status: TransactionStatus.completed,
      ),
      TransactionModel(
        id: 'tx3',
        type: TransactionType.withdrawal,
        title: 'Withdraw to Bank',
        date: 'MAR 11, 2026 • 2:00 PM',
        amount: 150.0,
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
    } else if (activeTxFilter.value == 'Withdrawls') {
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
}
