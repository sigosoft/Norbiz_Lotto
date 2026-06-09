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

    final profileHeader = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Obx(() => Row(
            children: [
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(
                  authController.userName.value.isNotEmpty ? authController.userName.value[0].toUpperCase() : 'U',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.primaryOrange),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authController.userName.value,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authController.userPhone.value,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => Get.to(() => const AccountInfoView()),
              ),
            ],
          )),
    );

    final walletCard = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'wallet_balance'.tr,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                '\$${authController.userWalletBalance.value.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: AppTheme.primaryDarkBlue),
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDepositDialog(context, accountController),
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                  label: Text('deposit'.tr, style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDarkBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showWithdrawDialog(context, accountController),
                  icon: const Icon(Icons.account_balance_outlined, size: 18),
                  label: Text('withdraw'.tr, style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryOrange,
                    side: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Profile shortcuts
    final shortcutButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildShortcutItem(Icons.receipt_long_outlined, 'bet_history'.tr, () {
          homeController.changeNavIndex(2); // Goes to history tab
        }),
        _buildShortcutItem(Icons.history_toggle_off, 'transactions'.tr, () {
          Get.to(() => const TransactionsView());
        }),
        _buildShortcutItem(Icons.account_balance_outlined, 'bank_accounts'.tr, () {
          Get.to(() => const BankAccountsView());
        }),
      ],
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Text(
              'account'.tr,
              style: const TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          backgroundColor: AppTheme.lightGreyBg,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                profileHeader,
                const SizedBox(height: 16),
                walletCard,
                const SizedBox(height: 24),
                shortcutButtons,
                const SizedBox(height: 24),
                
                // Menu List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(Icons.person_outline, 'account_info'.tr, () => Get.to(() => const AccountInfoView())),
                      _buildMenuItem(Icons.language_outlined, 'language'.tr, () => _showLanguageSelector(context, localizationController)),
                      _buildMenuItem(Icons.privacy_tip_outlined, 'privacy_policy'.tr, () => Get.to(() => const PolicyView(policyType: 'privacy'))),
                      _buildMenuItem(Icons.description_outlined, 'terms_conditions'.tr, () => Get.to(() => const PolicyView(policyType: 'terms'))),
                      _buildMenuItem(Icons.gavel_outlined, 'anti_fraud'.tr, () => Get.to(() => const PolicyView(policyType: 'fraud'))),
                      _buildMenuItem(Icons.child_care_outlined, 'under_18'.tr, () => Get.to(() => const PolicyView(policyType: 'age'))),
                      _buildMenuItem(Icons.headset_mic_outlined, 'help_center'.tr, () => Get.to(() => const HelpCenterView())),
                      
                      // Log out
                      _buildMenuItem(
                        Icons.logout, 
                        'logout'.tr, 
                        () => _showConfirmationDialog('logout'.tr, 'logout_confirm'.tr, () => Get.offAll(() => const SignInView())),
                        color: Colors.red,
                      ),
                      // Delete
                      _buildMenuItem(
                        Icons.delete_forever_outlined, 
                        'delete_account'.tr, 
                        () => _showConfirmationDialog('delete_account'.tr, 'delete_confirm'.tr, () => Get.offAll(() => const SignInView())),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShortcutItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryDarkBlue, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryDarkBlue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryDarkBlue),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color ?? AppTheme.primaryDarkBlue,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showConfirmationDialog(String title, String desc, VoidCallback onConfirm) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue)),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey)),
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

  void _showLanguageSelector(BuildContext context, LocalizationController locController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryDarkBlue),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('English'),
              trailing: locController.currentLanguage.value == 'en' ? const Icon(Icons.check, color: AppTheme.primaryOrange) : null,
              onTap: () {
                locController.changeLanguage('en');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Français'),
              trailing: locController.currentLanguage.value == 'fr' ? const Icon(Icons.check, color: AppTheme.primaryOrange) : null,
              onTap: () {
                locController.changeLanguage('fr');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Kreyòl Ayisyen'),
              trailing: locController.currentLanguage.value == 'ht' ? const Icon(Icons.check, color: AppTheme.primaryOrange) : null,
              onTap: () {
                locController.changeLanguage('ht');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, AccountController controller) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('deposit'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter Amount (\$USD)'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey))),
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
        title: Text('withdraw'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter Amount (\$USD)'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey))),
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
