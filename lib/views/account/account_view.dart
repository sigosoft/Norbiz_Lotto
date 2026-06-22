import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/localization_controller.dart';
import '../../controllers/account_controller.dart';
import '../auth/signin_view.dart';
import 'sub_account_views.dart';

class AccountView extends StatelessWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final homeController = Get.find<HomeController>();
    final accountController = Get.put(AccountController());
    final localizationController = Get.find<LocalizationController>();

    // Custom Header Row matching navigation and screenshot styling
    final customHeaderRow = Container(
      color: const Color(0xFFEFF3FD),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              final homeController = Get.find<HomeController>();
              homeController.changeNavIndex(0); // Goes to home tab
            },
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
          Text(
            'account'.tr,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 38), // Spacer of same width to center the title
        ],
      ),
    );

    // Profile Header Banner (Orange Box)
    final profileHeader = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(color: Color(0xFFFE9900)),
      child: Obx(
        () => Row(
          children: [
            Container(
              height: 64,
              width: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD15B),
                shape: BoxShape.circle,
              ),
              child: Text(
                authController.userName.value.isNotEmpty
                    ? authController.userName.value[0].toUpperCase()
                    : 'J',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authController.userName.value.isNotEmpty
                        ? authController.userName.value
                        : 'John Doe',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authController.userPhone.value.isNotEmpty
                        ? authController.userPhone.value
                        : '+1 (555) 012-3456',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const EditAccountInfoView()),
              child: const Icon(Icons.edit, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );

    // Wallet Card (Total Available Balance with deposit/withdraw capsule buttons)
    final walletCard = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                "lib/assets/images/Available.png",
                width: 34,
                height: 34,
                color: const Color.fromARGB(255, 32, 31, 31),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'wallet_balance'.tr,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  '\$${authController.userWalletBalance.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF002C8B).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            _showDepositDialog(context, accountController),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002C8B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          minimumSize: const Size(0, 44),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "lib/assets/images/Deposit.png",
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'deposit'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFE9900).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            _showWithdrawDialog(context, accountController),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE9900),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          minimumSize: const Size(0, 44),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "lib/assets/images/Withdraw.png",
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'withdraw'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // Profile Shortcuts (Bet History, Transactions, Bank Accounts)
    final shortcutButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShortcutItem(
          const ImageIcon(
            AssetImage('lib/assets/images/BottomBetHistory.png'),
            color: Color(0xFFFE9900),
            size: 20,
          ),
          'bet_history'.tr,
          () => homeController.changeNavIndex(2),
        ),
        _buildShortcutItem(
          const ImageIcon(
            AssetImage('lib/assets/images/transactions.png'),
            color: Color(0xFFFE9900),
            size: 20,
          ),
          'transactions'.tr,
          () => Get.to(() => const TransactionsView()),
        ),
        _buildShortcutItem(
          const ImageIcon(
            AssetImage('lib/assets/images/bank accounts.png'),
            color: Color(0xFFFE9900),
            size: 20,
          ),
          'bank_accounts'.tr,
          () => Get.to(() => const BankAccountsView()),
        ),
      ],
    );

    // Custom "18+" logo icon widget
    final custom18Logo = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF64748B), width: 2),
      ),
      alignment: Alignment.center,
      child: const Text(
        '18+',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: Color(0xFF64748B),
        ),
      ),
    );

    // Centered Log Out Button
    final logoutButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: InkWell(
          onTap: () => _showLogoutBottomSheet(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "lib/assets/images/logout.png",
                height: 20,
                width: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'logout'.tr,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Social Media Icons Row
    final socialMediaRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Facebook
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Image.asset(
            "lib/assets/images/Facebook.png",
            width: 35,
            height: 35,
          ),
        ),
        // Instagram
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 39,
          height: 39,
          alignment: Alignment.center,
          child: Image.asset(
            "lib/assets/images/Instagram.png",
            width: 39,
            height: 39,
          ),
        ),
        // LinkedIn
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Image.asset(
            "lib/assets/images/LinkedIn.png",
            width: 35,
            height: 35,
          ),
        ),
        // Twitter/X
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Image.asset(
            "lib/assets/images/Twitter.png",
            width: 32,
            height: 32,
          ),
        ),
        // YouTube
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Image.asset(
            "lib/assets/images/YouTube.png",
            width: 36,
            height: 36,
          ),
        ),
      ],
    );

    // Version Footer with Update Check
    final versionFooter = Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
      child: Column(
        children: [
          const Text(
            'v2.8.1',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'System Update',
                'You are running the latest version.',
                backgroundColor: Colors.white.withOpacity(0.9),
                colorText: const Color(0xFF0D319C),
              );
            },
            child: const Text(
              'Check for update',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  customHeaderRow,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          profileHeader,
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                walletCard,
                                const SizedBox(height: 20),
                                shortcutButtons,
                                const SizedBox(height: 24),

                                // Menu items list directly on background
                                Column(
                                  children: [
                                    _buildMenuItem(
                                      leading: Image.asset(
                                        "lib/assets/images/AccountInfo.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      title: 'account_info'.tr,
                                      onTap: () =>
                                          Get.to(() => const AccountInfoView()),
                                    ),
                                    _buildMenuItem(
                                      leading: Image.asset(
                                        "lib/assets/images/Languages.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      title: 'language'.tr,
                                      onTap: () => _showLanguageSelector(
                                        context,
                                        localizationController,
                                      ),
                                    ),
                                    _buildMenuItem(
                                      leading: Image.asset(
                                        "lib/assets/images/PrivacyPolicy.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      title: 'privacy_policy'.tr,
                                      onTap: () => Get.to(
                                        () => const PolicyView(
                                          policyType: 'privacy',
                                        ),
                                      ),
                                    ),
                                    _buildMenuItem(
                                      leading: Image.asset(
                                        "lib/assets/images/Terms&Conditions.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      title: 'terms_conditions'.tr,
                                      onTap: () => Get.to(
                                        () => const PolicyView(
                                          policyType: 'terms',
                                        ),
                                      ),
                                    ),
                                    _buildMenuItem(
                                      leading: Image.asset(
                                        "lib/assets/images/AntiFraud.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      title: 'anti_fraud'.tr,
                                      onTap: () => Get.to(
                                        () => const PolicyView(
                                          policyType: 'fraud',
                                        ),
                                      ),
                                    ),
                                    _buildMenuItem(
                                      leading: Image.asset(
                                        "lib/assets/images/Under-18.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      title: 'under_18'.tr,
                                      onTap: () => Get.to(
                                        () =>
                                            const PolicyView(policyType: 'age'),
                                      ),
                                    ),
                                    _buildMenuItem(
                                      leading: Image.asset(
                                        "lib/assets/images/HelpCenter.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      title: 'help_center'.tr,
                                      onTap: () =>
                                          Get.to(() => const HelpCenterView()),
                                    ),
                                  ],
                                ),

                                logoutButton,
                                socialMediaRow,
                                versionFooter,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShortcutItem(
    Widget iconWidget,
    String label,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF002C8B),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: iconWidget,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget leading,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              SizedBox(width: 24, height: 24, child: Center(child: leading)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    String title,
    String desc,
    VoidCallback onConfirm,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDarkBlue,
          ),
        ),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(80, 38),
            ),
            child: Text('yes'.tr),
          ),
        ],
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    final authController = Get.find<AuthController>();
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Close Button
              Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Logout',
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
                'Are you sure you want to logout?',
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
                          'No',
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
                          authController.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE9900),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Logout',
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
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showLanguageSelector(
    BuildContext context,
    LocalizationController locController,
  ) {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'language'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primaryDarkBlue,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('English'),
                trailing: locController.currentLanguage.value == 'en'
                    ? const Icon(Icons.check, color: AppTheme.primaryOrange)
                    : null,
                onTap: () {
                  locController.changeLanguage('en');
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('Français'),
                trailing: locController.currentLanguage.value == 'fr'
                    ? const Icon(Icons.check, color: AppTheme.primaryOrange)
                    : null,
                onTap: () {
                  locController.changeLanguage('fr');
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('Kreyòl Ayisyen'),
                trailing: locController.currentLanguage.value == 'ht'
                    ? const Icon(Icons.check, color: AppTheme.primaryOrange)
                    : null,
                onTap: () {
                  locController.changeLanguage('ht');
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, AccountController controller) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'deposit'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter Amount (\$USD)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              double amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                controller.depositFunds(amount);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 38)),
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, AccountController controller) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'withdraw'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter Amount (\$USD)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              double amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                if (controller.withdrawFunds(amount)) {
                  Get.back();
                }
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 38)),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
