import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/account_controller.dart';
import '../../models/bank_model.dart';
import '../../models/transaction_model.dart';
import '../../configs/toast.dart';

// ------------------------------------------------------------
// 1. Account Info / Edit Profile View
// ------------------------------------------------------------
class AccountInfoView extends StatelessWidget {
  const AccountInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    final firstNameController = TextEditingController(text: authController.userName.value.split(' ').first);
    final lastNameController = TextEditingController(text: authController.userName.value.split(' ').last);
    final phoneController = TextEditingController(text: authController.userPhone.value);
    final emailController = TextEditingController(text: authController.userEmail.value);
    final dobController = TextEditingController(text: authController.userDob.value);
    var genderVal = authController.userGender.value.obs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryDarkBlue),
          onPressed: () => Get.back(),
        ),
        title: Text('account_info'.tr, style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('first_name'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 6),
            TextField(controller: firstNameController),
            const SizedBox(height: 16),
            
            Text('last_name'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 6),
            TextField(controller: lastNameController),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('gender'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGrey)),
                      const SizedBox(height: 6),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreyBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: genderVal.value,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'Male', child: Text('Male')),
                                DropdownMenuItem(value: 'Female', child: Text('Female')),
                              ],
                              onChanged: (val) {
                                if (val != null) genderVal.value = val;
                              },
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('dob'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGrey)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: dobController,
                        decoration: const InputDecoration(hintText: 'YYYY-MM-DD'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text('phone_number'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 6),
            TextField(controller: phoneController),
            const SizedBox(height: 16),
            
            Text('Email', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 6),
            TextField(controller: emailController),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () {
                authController.updateProfile(
                  firstNameController.text,
                  lastNameController.text,
                  phoneController.text,
                  emailController.text,
                  genderVal.value,
                  dobController.text,
                );
                Get.back();
                showToast('Profile updated successfully.'.tr, title: 'Success');
              },
              child: Text('save'.tr),
            ),
            const SizedBox(height: 16),
            
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'delete_account'.tr,
                    content: Text('delete_confirm'.tr),
                    textCancel: 'cancel'.tr,
                    textConfirm: 'delete'.tr,
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () => Get.offAllNamed('/login'),
                  );
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text('delete_account'.tr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 2. Wallet Transactions List View
// ------------------------------------------------------------
class TransactionsView extends StatelessWidget {
  const TransactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryDarkBlue),
          onPressed: () => Get.back(),
        ),
        title: Text('transactions'.tr, style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: AppTheme.lightGreyBg,
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: ['All', 'Deposits', 'Withdrawls'].map((filter) {
                return Obx(() {
                  final isSelected = accountController.activeTxFilter.value == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => accountController.changeTxFilter(filter),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryOrange : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade300),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.primaryDarkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
          ),
          
          Expanded(
            child: Obx(() {
              final list = accountController.filteredTransactions;
              if (list.isEmpty) {
                return const Center(child: Text('No transaction history.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final tx = list[index];
                  final isDeposit = tx.type == TransactionType.deposit;
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDeposit ? Colors.green.shade50 : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isDeposit ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(tx.date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isDeposit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDeposit ? Colors.green : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildTxStatusTag(tx.status),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildTxStatusTag(TransactionStatus status) {
    String label = 'Completed';
    Color bg = Colors.green.shade50;
    Color textCol = Colors.green;

    if (status == TransactionStatus.processing) {
      label = 'Processing';
      bg = Colors.orange.shade50;
      textCol = Colors.orange;
    } else if (status == TransactionStatus.failed) {
      label = 'Failed';
      bg = Colors.red.shade50;
      textCol = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: textCol),
      ),
    );
  }
}

// ------------------------------------------------------------
// 3. Bank Accounts / Withdrawal Targets
// ------------------------------------------------------------
class BankAccountsView extends StatelessWidget {
  const BankAccountsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryDarkBlue),
          onPressed: () => Get.back(),
        ),
        title: Text('bank_accounts'.tr, style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: AppTheme.lightGreyBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'saved_accounts'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue, fontSize: 15),
            ),
            const SizedBox(height: 12),
            
            // Accounts List
            Obx(() => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: accountController.savedAccounts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final acc = accountController.savedAccounts[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.primaryOrange.withOpacity(0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance, color: AppTheme.primaryOrange),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc.accountHolder,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${acc.bankName} • ${acc.accountNumber}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => accountController.deleteBankAccount(acc.id),
                          ),
                        ],
                      ),
                    );
                  },
                )),
            
            const SizedBox(height: 20),
            
            // Add another account container with dash border
            GestureDetector(
              onTap: () => _showAddAccountSheet(context, accountController),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryOrange, width: 1.5, style: BorderStyle.solid), // Dash mock
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_card_outlined, color: AppTheme.primaryOrange, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'add_bank'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'withdraw_desc'.tr,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountSheet(BuildContext context, AccountController controller) {
    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final bankController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'add_bank'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryDarkBlue),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: holderController,
                decoration: const InputDecoration(hintText: 'Account Holder Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Account Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bankController,
                decoration: const InputDecoration(hintText: 'Bank Name'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (holderController.text.isNotEmpty && numberController.text.isNotEmpty && bankController.text.isNotEmpty) {
                    controller.addBankAccount(holderController.text, numberController.text, bankController.text);
                  }
                },
                child: const Text('Add Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 4. Policy (Privacy, Terms, Anti-Fraud, Under-18) HTML mock
// ------------------------------------------------------------
class PolicyView extends StatelessWidget {
  final String policyType;

  const PolicyView({Key? key, required this.policyType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = '';
    String content = '';

    if (policyType == 'privacy') {
      title = 'privacy_policy'.tr;
      content = 'Norbiz Lotto values your privacy. This policy documents how we collect, store, and process your user credentials, device identifiers, and wallet transactions securely.\n\nWe utilize industry standard high-end cryptography to protect sensitive information.';
    } else if (policyType == 'terms') {
      title = 'terms_conditions'.tr;
      content = 'These terms and conditions govern your use of the Norbiz Lotto platform. By registering and placing bets, you confirm that you are at least 18 years of age.\n\nAll lottery results are verified against state drawings and payouts are subject to calculation rules.';
    } else if (policyType == 'fraud') {
      title = 'anti_fraud'.tr;
      content = 'Norbiz Lotto maintains a strict zero-tolerance policy regarding anti-fraud. Any user accounts displaying patterns of manipulation, fake payments, or double spending will face immediate suspension and legal report.\n\nWe audit all wallet activities.';
    } else {
      title = 'under_18'.tr;
      content = 'Under-18 Protection Policy:\nNorbiz Lotto is committed to preventing underage gambling. We require mobile validation, ID verification, and age checks during signup.\n\nParents are encouraged to monitor devices.';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryDarkBlue),
          onPressed: () => Get.back(),
        ),
        title: Text(title, style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.primaryDarkBlue),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 5. Help Center Support Channels
// ------------------------------------------------------------
class HelpCenterView extends StatelessWidget {
  const HelpCenterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryDarkBlue),
          onPressed: () => Get.back(),
        ),
        title: Text('help_center'.tr, style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: AppTheme.lightGreyBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // WhatsApp Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.green, size: 28),
                      SizedBox(width: 12),
                      Text('WhatsApp Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDarkBlue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Chat with us directly on your mobile device for on-the-go support.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      showToast('Redirecting to WhatsApp chat...', title: 'WhatsApp Support');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Start Chat'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Email Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.email_outlined, color: AppTheme.primaryOrange, size: 28),
                      SizedBox(width: 12),
                      Text('Email Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDarkBlue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Detailed inquiries? Send us an email and we will reply within 2 hours.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      showToast('Opening email composer...', title: 'Email Support');
                    },
                    child: const Text('Send Mail'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Support hours detail
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Support Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryDarkBlue)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Business Hours: 9:00 AM - 10:00 PM', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('WhatsApp: +1 123 456 7800', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.mail_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Email: support@norbizlotto.com', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
