import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/account_controller.dart';
import '../../models/bank_model.dart';
import '../../models/transaction_model.dart';
import '../../configs/toast.dart';
import '../auth/signin_view.dart';

// ------------------------------------------------------------
// 1. Account Info / Edit Profile View
// ------------------------------------------------------------
class AccountInfoView extends StatelessWidget {
  const AccountInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    final firstNameController = TextEditingController(
      text: authController.userName.value.split(' ').first,
    );
    final lastNameController = TextEditingController(
      text: authController.userName.value.split(' ').last,
    );
    final phoneController = TextEditingController(
      text: authController.userPhone.value,
    );
    final emailController = TextEditingController(
      text: authController.userEmail.value,
    );
    final dobController = TextEditingController(
      text: authController.userDob.value,
    );
    var genderVal = authController.userGender.value.obs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primaryDarkBlue,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'account_info'.tr,
          style: const TextStyle(
            color: AppTheme.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'first_name'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 6),
            TextField(controller: firstNameController),
            const SizedBox(height: 16),

            Text(
              'last_name'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 6),
            TextField(controller: lastNameController),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'gender'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => Container(
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
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) genderVal.value = val;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dob'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          hintText: 'YYYY-MM-DD',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'phone_number'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 6),
            TextField(controller: phoneController),
            const SizedBox(height: 16),

            Text(
              'Email',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
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
                onPressed: () => _showDeleteAccountBottomSheet(context),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  'delete_account'.tr,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Close Button
            Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 36,
                      width: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Subtitle
            const Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF7ED),
                        foregroundColor: const Color(0xFFFE9900),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.offAll(() => const SignInView());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE9900),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primaryDarkBlue,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'transactions'.tr,
          style: const TextStyle(
            color: AppTheme.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  final isSelected =
                      accountController.activeTxFilter.value == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => accountController.changeTxFilter(filter),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryOrange
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryOrange
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.primaryDarkBlue,
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
                            color: isDeposit
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDeposit
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDarkBlue,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tx.date,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
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
          ),
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 8,
          color: textCol,
        ),
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primaryDarkBlue,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'bank_accounts'.tr,
          style: const TextStyle(
            color: AppTheme.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDarkBlue,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),

            // Accounts List
            Obx(
              () => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accountController.savedAccounts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
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
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                acc.accountHolder,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDarkBlue,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${acc.bankName} • ${acc.accountNumber}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () =>
                              accountController.deleteBankAccount(acc.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Add another account container with dash border
            GestureDetector(
              onTap: () => _showAddAccountSheet(context, accountController),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryOrange,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ), // Dash mock
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.add_card_outlined,
                      color: AppTheme.primaryOrange,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'add_bank'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryOrange,
                        fontSize: 14,
                      ),
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

  void _showAddAccountSheet(
    BuildContext context,
    AccountController controller,
  ) {
    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final bankController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'add_bank'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primaryDarkBlue,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: holderController,
                decoration: const InputDecoration(
                  hintText: 'Account Holder Name',
                ),
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
                  if (holderController.text.isNotEmpty &&
                      numberController.text.isNotEmpty &&
                      bankController.text.isNotEmpty) {
                    controller.addBankAccount(
                      holderController.text,
                      numberController.text,
                      bankController.text,
                    );
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
    if (policyType == 'privacy') {
      return _buildPrivacyPolicy(context);
    }
    if (policyType == 'terms') {
      return _buildTermsAndConditions(context);
    }
    if (policyType == 'fraud') {
      return _buildAntiFraudPolicy(context);
    }
    return _buildUnder18Policy(context);
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row matching screen exactly
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Norbiz Lotto ("we", "our", "the Company") is committed to protecting your personal information and ensuring transparency in how your data is collected, used, and safeguarded. This Privacy Policy explains the types of information we collect, how we use it, and the rights you have regarding your data',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Information We Collect"),
                    const SizedBox(height: 8),
                    const Text(
                      "We may collect the following categories of information:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Personal Identification: ",
                          "full name, date of birth, gender",
                        ),
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Contact Information: ",
                          "phone number, email address",
                        ),
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Account Information: ",
                          "login credentials, wallet balance, transaction history",
                        ),
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Device Information: ",
                          "IP address, device type, operating system, usage analytics",
                        ),
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Verification Data: ",
                          "identity documents, age verification, anti-fraud checks",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("How We Use Your Information"),
                    const SizedBox(height: 8),
                    const Text(
                      "Your information is used to:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Create and manage your Norbiz Lotto account",
                        ),
                        _buildBulletItem(
                          "Process deposits, withdrawols, and lottery bets",
                        ),
                        _buildBulletItem("Verify identity and prevent fraud"),
                        _buildBulletItem("Provide customer support"),
                        _buildBulletItem(
                          "Improve app performance and user experience",
                        ),
                        _buildBulletItem(
                          "Comply with legal and regulatory requirements",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Data Sharing"),
                    const SizedBox(height: 8),
                    const Text(
                      "We may share your information with:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Licensed payment processors"),
                        _buildBulletItem("Identity verification partners"),
                        _buildBulletItem(
                          "Regulatory authorities (when required by law)",
                        ),
                        _buildBulletItem(
                          "Fraud-prevention and security partners",
                        ),
                      ],
                      footer: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF3FD),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(19),
                            bottomRight: Radius.circular(19),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "We do not sell your personal information .",
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Data Security"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        const Text(
                          "We use encryption, secure servers, and continuous monitoring to protect your data from unauthorized access or misuse.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Your Rights"),
                    const SizedBox(height: 8),
                    const Text(
                      "You may:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Request access to your data"),
                        _buildBulletItem("Request corrections"),
                        _buildBulletItem(
                          "Request deletion (subject to legal retention rules)",
                        ),
                        _buildBulletItem("Withdraw consent"),
                        _buildBulletItem("Request a copy of your data"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Data Retention"),
                    const SizedBox(height: 8),
                    const Text(
                      "We retain your information only as long as necessary for:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Legal compliance"),
                        _buildBulletItem("Transaction history"),
                        _buildBulletItem("Anti-fraud monitoring"),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002C8B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Questions?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Our team is available to assist you with any concerns.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Optional email client launch trigger (handled cleanly)
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE9900),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFFFE9900),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "support@norbizlotto.com",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFFE9900),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0D47A1),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children, Widget? footer}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          if (footer != null) footer,
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 6.0,
        bottom: 6.0,
        right: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•  ",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItemWithBoldPrefix(
    BuildContext context,
    String boldPrefix,
    String normalText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 6.0,
        bottom: 6.0,
        right: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•  ",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: boldPrefix,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: normalText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'These Terms & Conditions govern your use of the Norbiz Lotto mobile application and services. By creating an account or placing a bet, you agree to these terms',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Eligibility"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "You must be 18 years or older to use the platform",
                        ),
                        _buildBulletItem(
                          "You must provide accurate and verifiable information",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Account Registration"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        const Text(
                          "Users must register with a valid phone number and maintain the confdentiality of their login credentials",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Betting Rules"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("All bets are final once confirmed"),
                        _buildBulletItem(
                          "Bets cannot be modified or cancelled after submission",
                        ),
                        _buildBulletItem(
                          "Winnings are calculated based on the official draw results",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Wallet & Payments"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Deposits must come from authorized payment methods",
                        ),
                        _buildBulletItem(
                          "Withdrawals may require identity verification",
                        ),
                        _buildBulletItem(
                          "The Company may apply service fees where applicable",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Fraud & Misconduct"),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto reserves the right to suspend or terminate accounts involved in:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Fraudulent activity"),
                        _buildBulletItem("Multiple account creation"),
                        _buildBulletItem("Manipulation of results"),
                        _buildBulletItem(
                          "Chargebacks or unauthorized transactions",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Limitation of Liability"),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto is not responsible for:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Network issues"),
                        _buildBulletItem(
                          "Delays caused by third-party providers",
                        ),
                        _buildBulletItem(
                          "Incorrect information submitted by users",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Changes to Terms"),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto is not responsible for:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        const Text(
                          "We may update these Terms & Conditions at any time. Continued use of the app constitutes acceptance of the updated terms.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002C8B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Questions?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Our team is available to assist you with any concerns.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Optional email client launch trigger (handled cleanly)
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE9900),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFFFE9900),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "support@norbizlotto.com",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntiFraudPolicy(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Anti-Fraud Policy',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Norbiz Lotto is committed to maintaining a secure, transparent, and fair gaming environment. This Anti-Fraud Policy outlines the measures we take to detect, prevent, and respond to fraudulent activity',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Purpose"),
                    const SizedBox(height: 8),
                    const Text(
                      "This policy ensures:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Fair play"),
                        _buildBulletItem("Protection of user accounts"),
                        _buildBulletItem(
                          "Integrity of all lottery transactions",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Prohibited Activities"),
                    const SizedBox(height: 8),
                    const Text(
                      "The following actions are strictly forbidden:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Creating multiple accounts"),
                        _buildBulletItem(
                          "Using false or stolen identity information",
                        ),
                        _buildBulletItem("Manipulating betting systems"),
                        _buildBulletItem(
                          "Attempting to interfere with draw results",
                        ),
                        _buildBulletItem(
                          "Unauthorized access to another user's account",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Monitoring & Detection"),
                    const SizedBox(height: 8),
                    const Text(
                      "We use:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Automated fraud-detection systems"),
                        _buildBulletItem(
                          "Manual review of suspicious transactions",
                        ),
                        _buildBulletItem("Device fingerprinting"),
                        _buildBulletItem("IP and geolocation checks"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Verification Requirements"),
                    const SizedBox(height: 8),
                    const Text(
                      "We may request:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Government-issued ID"),
                        _buildBulletItem("Proof of address"),
                        _buildBulletItem("Proof of payment ownership"),
                      ],
                      footer: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF3FD),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(19),
                            bottomRight: Radius.circular(19),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Failure to comply may result in account suspension",
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Consequences of Fraud"),
                    const SizedBox(height: 8),
                    const Text(
                      "If fraud is detected, Norbiz Lotto may:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Freeze the account"),
                        _buildBulletItem("Cancel pending bets"),
                        _buildBulletItem("Withhold winnings"),
                        _buildBulletItem("Report the case to authorities"),
                        _buildBulletItem("Permanently ban the user"),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002C8B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Reporting Fraud",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Users may report suspicious activity to",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Optional email client launch trigger (handled cleanly)
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE9900),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFFFE9900),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "support@norbizlotto.com",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnder18Policy(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Under-18 Protection',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Norbiz Lotto is fully committed to preventing minors from accessing, participating in, or being exposed to any form of gambling activity. This policy establishes strict measures to ensure that individuals under the age of 18 are protected at all times',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Zero-Tolerance Rule"),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto maintains a strict zero-tolerance policy regarding under-age gambling. No person under the age of 18 years is permitted to:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Create an account"),
                        _buildBulletItem("Access the platform"),
                        _buildBulletItem(
                          "Place bets or participate in any game",
                        ),
                        _buildBulletItem("Make deposits or withdrawals"),
                        _buildBulletItem("Claim winnings"),
                        _buildBulletItem(
                          "Use any Norbiz Lotto service, directly or indirectly",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Any attempt to bypass age restrictions will result in immediate account suspension and notification to the appropriate authorities if required",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Age Verification Procedures"),
                    const SizedBox(height: 8),
                    const Text(
                      "To ensure full compliance, Norbiz Lotto implements multi-layered verification:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Mandatory identity verification (ID, passport, or national document)",
                        ),
                        _buildBulletItem(
                          "Proof of age validated through official documents",
                        ),
                        _buildBulletItem(
                          "Automated system checks to detect inconsistencies",
                        ),
                        _buildBulletItem(
                          "Manual review by the Compliance Team when necessary",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No account becomes fully active until age verification is successfully completed",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Parental & Guardian Responsibility"),
                    const SizedBox(height: 8),
                    const Text(
                      "Parents and legal guardians are encouraged to:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Monitor devices accessible to minors",
                        ),
                        _buildBulletItem("Use parental control tools"),
                        _buildBulletItem(
                          "Ensure minors do not have access to payment methods linked to gambling",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Norbiz Lotto cannot be held responsible for unauthorized access resulting from negligence by parents or guardians",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      "Marketing & Communication Restrictions",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto strictly prohibits:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Any marketing material targeting minors",
                        ),
                        _buildBulletItem(
                          "Use of imagery, language, or themes appealing to children",
                        ),
                        _buildBulletItem(
                          "Advertising on platforms primarily used by minors",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "All communication is designed for an adult audience only",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      "Account Monitoring & Fraud Prevention",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "The platform uses advanced monitoring tools to detect:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Suspicious activity suggesting under-age access",
                        ),
                        _buildBulletItem(
                          "Accounts created using fake or borrowed identification",
                        ),
                        _buildBulletItem(
                          "Attempts by adults to place bets on behalf of minors",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Any violation leads to permanent account closure",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Reporting Under-Age Gambling"),
                    const SizedBox(height: 8),
                    const Text(
                      "The platform uses advanced monitoring tools to detect:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        const Text(
                          "Users, partners, and third parties are encouraged to report any suspicion of under-age gambling. Reports can be submitted to the Norbiz Lotto Compliance Department for immediate investigation",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      "Compliance With International Standards",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "This policy aligns with:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "International responsible gaming standards",
                        ),
                        _buildBulletItem("Anti-fraud and KYC regulations"),
                        _buildBulletItem(
                          "Local and international gambling compliance frameworks",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Norbiz Lotto ensures continuous updates to remain aligned with evolving legal requirements.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Enforcement & Sanctions"),
                    const SizedBox(height: 8),
                    const Text(
                      "Any breach of this policy results in:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Immediate account suspension"),
                        _buildBulletItem(
                          "Confiscation of funds if required by law",
                        ),
                        _buildBulletItem(
                          "Notification to regulatory authorities",
                        ),
                        _buildBulletItem(
                          "Permanent exclusion from the platform",
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002C8B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Reporting Fraud",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Users may report suspicious activity to",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Optional email client launch trigger (handled cleanly)
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE9900),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFFFE9900),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "support@norbizlotto.com",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8EDF9), Color(0xFFF6F8FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header Row matching screen exactly
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                height: 62,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 38,
                          width: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xFF0F172A),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Help Center',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // WhatsApp Card
                      _buildWhatsAppCard(),
                      const SizedBox(height: 16),

                      // Email Support Card
                      _buildEmailCard(),
                      const SizedBox(height: 16),

                      // Support Info Card
                      _buildSupportInfoCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'lib/assets/images/whatsapp.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'WhatsApp',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chat with us directly on your mobile device for on-the-go support.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                showToast(
                  'Redirecting to WhatsApp chat...',
                  title: 'WhatsApp Support',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE9900),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Start Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'lib/assets/images/mail.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Email Support',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Detailed inquiries? Send us an email and we'll reply within 2 hours.",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                showToast('Opening email composer...', title: 'Email Support');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE9900),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Send Mail',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            iconWidget: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFFFE9900),
              size: 24,
            ),
            title: 'Business Hours',
            subtitle: 'Available 9 AM - 10 PM',
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            iconWidget: Image.asset(
              'lib/assets/images/whatsapp.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            title: 'WhatsApp',
            subtitle: '+1 1234567800',
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            iconWidget: Image.asset(
              'lib/assets/images/mail.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            title: 'Support Email',
            subtitle: 'support@norbizlotto.com',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required Widget iconWidget,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        SizedBox(width: 24, height: 24, child: Center(child: iconWidget)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }
}
