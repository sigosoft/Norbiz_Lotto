import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/localization_controller.dart';
import 'signin_view.dart';
import '../../configs/toast.dart';

class CreatePasswordView extends StatelessWidget {
  const CreatePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final localizationController = Get.find<LocalizationController>();

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Custom Top Action Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.black,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'create_new_password'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Brand Logo
                          Image.asset(
                            'lib/assets/images/Logo.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 40),

                          // Form Fields
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Enter New Password Label
                                Text(
                                  'enter_new_password'.tr,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // New Password Input Box
                                Container(
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: TextField(
                                            controller: authController
                                                .newPasswordController,
                                            obscureText: !authController
                                                .isNewPasswordVisible
                                                .value,
                                            style: const TextStyle(
                                              color: AppTheme.textDark,
                                              fontSize: 16,
                                            ),
                                            decoration: const InputDecoration(
                                              filled: false,
                                              isDense: true,
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          authController
                                                  .isNewPasswordVisible
                                                  .value
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: authController
                                            .toggleNewPasswordVisibility,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Enter Confirm Password Label
                                Text(
                                  'enter_confirm_password'.tr,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Confirm Password Input Box
                                Container(
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: TextField(
                                            controller: authController
                                                .newConfirmPasswordController,
                                            obscureText: !authController
                                                .isNewConfirmPasswordVisible
                                                .value,
                                            style: const TextStyle(
                                              color: AppTheme.textDark,
                                              fontSize: 16,
                                            ),
                                            decoration: const InputDecoration(
                                              filled: false,
                                              isDense: true,
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          authController
                                                  .isNewConfirmPasswordVisible
                                                  .value
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: authController
                                            .toggleNewConfirmPasswordVisibility,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Action Button (Continue)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Obx(
                              () => authController.isLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppTheme.buttonOrange,
                                            ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          bool success = await authController
                                              .confirmPasswordReset();
                                          if (success) {
                                            showToast(
                                              'Password reset successfully.'.tr,
                                              title: 'Success',
                                            );
                                            Get.offAll(
                                              () => const SignInView(),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.buttonOrange,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'continue'.tr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
