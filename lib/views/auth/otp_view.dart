import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/localization_controller.dart';
import '../../configs/toast.dart';
import '../navigation/main_navigation_view.dart';
import 'create_password_view.dart';

class OtpView extends StatelessWidget {
  final bool isResetPasswordFlow;

  const OtpView({Key? key, this.isResetPasswordFlow = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final localizationController = Get.find<LocalizationController>();

    final String phoneNum = isResetPasswordFlow
        ? authController.resetPhoneController.text
        : authController.signUpPhoneController.text;

    final logoWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppTheme.lightGreyBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.casino_rounded,
            color: AppTheme.primaryDarkBlue,
            size: 56,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'NORBIZ PARYAJ',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDarkBlue,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );

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
                                  'verification'.tr,
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

                          // Description Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'verification_sent'.trParams({
                                'phone':
                                    '${authController.selectedCountryDialCode.value} $phoneNum',
                              }),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Centered group container for OTP boxes + Resend countdown
                          SizedBox(
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (index) {
                                    return SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: Center(
                                        child: TextField(
                                          controller: authController
                                              .otpControllers[index],
                                          focusNode: authController
                                              .otpFocusNodes[index],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          maxLength: 1,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                          decoration: InputDecoration(
                                            counterText: "",
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: EdgeInsets.zero,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: AppTheme.buttonOrange,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty && index < 5) {
                                              authController
                                                  .otpFocusNodes[index + 1]
                                                  .requestFocus();
                                            } else if (value.isEmpty &&
                                                index > 0) {
                                              authController
                                                  .otpFocusNodes[index - 1]
                                                  .requestFocus();
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 12),
                                // Resend timer text / button
                                Obx(() {
                                  int timerVal =
                                      authController.otpCountdown.value;
                                  if (timerVal > 0) {
                                    String seconds = (timerVal % 60)
                                        .toString()
                                        .padLeft(2, '0');
                                    String minutes = (timerVal ~/ 60)
                                        .toString()
                                        .padLeft(2, '0');
                                    String timeStr = '$minutes:$seconds';
                                    final translation = 'resend_code'.trParams({
                                      'time': timeStr,
                                    });

                                    if (translation.contains(timeStr)) {
                                      final parts = translation.split(timeStr);
                                      return RichText(
                                        text: TextSpan(
                                          text: parts[0],
                                          style: const TextStyle(
                                            color: Color(0xFF1E1E1E),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: timeStr,
                                              style: const TextStyle(
                                                color: AppTheme.buttonOrange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (parts.length > 1)
                                              TextSpan(
                                                text: parts[1],
                                                style: const TextStyle(
                                                  color: Color(0xFF1E1E1E),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        translation,
                                        style: const TextStyle(
                                          color: Color(0xFF1E1E1E),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  } else {
                                    String lang = localizationController
                                        .currentLanguage
                                        .value;
                                    String btnText = 'Resend Code';
                                    if (lang == 'fr')
                                      btnText = 'Renvoyer le code';
                                    if (lang == 'ht') btnText = 'Voye Kòd ankò';
                                    return TextButton(
                                      onPressed: authController.resendOtp,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        btnText,
                                        style: const TextStyle(
                                          color: AppTheme.buttonOrange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }
                                }),
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
                                          String otp = authController
                                              .otpControllers
                                              .map((c) => c.text)
                                              .join()
                                              .trim();
                                          if (otp.length < 6) {
                                            showToast(
                                              'Please enter the 6-digit verification code.'
                                                  .tr,
                                              title: 'Error',
                                            );
                                            return;
                                          }

                                          if (isResetPasswordFlow) {
                                            bool success = await authController.verifyOtp();
                                            if (success) {
                                              for (var c
                                                  in authController
                                                      .otpControllers) {
                                                c.clear();
                                              }
                                              Get.off(
                                                () => const CreatePasswordView(),
                                              );
                                            }
                                          } else {
                                            if (otp != "123456") {
                                              showToast(
                                                'Invalid verification code.'.tr,
                                                title: 'Error',
                                              );
                                              return;
                                            }
                                            bool success = await authController
                                                .register();
                                            if (success) {
                                              for (var c
                                                  in authController
                                                      .otpControllers) {
                                                c.clear();
                                              }
                                              Get.offAll(
                                                () =>
                                                    const MainNavigationView(),
                                              );
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 300,
                                                ),
                                                () => showToast(
                                                  'Registration successful.'.tr,
                                                  title: 'Success',
                                                ),
                                              );
                                            }
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
