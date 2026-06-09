import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/localization_controller.dart';
import 'signin_view.dart';
import 'otp_view.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final localizationController = Get.find<LocalizationController>();
    final size = MediaQuery.of(context).size;

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 203, 220, 243),
                  Color.fromARGB(255, 213, 228, 249),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Top action bar (Language Pill & Close Button)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.045,
                                vertical: size.height * 0.012,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLanguageSelector(
                                    size,
                                    localizationController,
                                  ),
                                  _buildCloseButton(size),
                                ],
                              ),
                            ),

                            const SizedBox(height: 35),

                            // Brand Logo
                            Image.asset(
                              'lib/assets/images/Logo.png',
                              height: size.height * 0.16,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 10),

                            // "Sign Up !" Text above sheet
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'sign_up'.tr,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.buttonOrange,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Bottom Sheet Container with White-to-Blue Gradient
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: AppTheme.loginSheetGradient,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  20,
                                  24,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // First Name & Last Name Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'first_name'.tr,
                                                style: const TextStyle(
                                                  color: Color(0xFF4A4A4A),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 45,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.02),
                                                      blurRadius: 6,
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: TextField(
                                                    controller: authController
                                                        .signUpFirstNameController,
                                                    style: const TextStyle(
                                                      color: AppTheme.textDark,
                                                      fontSize: 16,
                                                    ),
                                                    decoration:
                                                        const InputDecoration(
                                                          filled: false,
                                                          isDense: true,
                                                          border:
                                                              InputBorder.none,
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'last_name'.tr,
                                                style: const TextStyle(
                                                  color: Color(0xFF4A4A4A),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 45,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.02),
                                                      blurRadius: 6,
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: TextField(
                                                    controller: authController
                                                        .signUpLastNameController,
                                                    style: const TextStyle(
                                                      color: AppTheme.textDark,
                                                      fontSize: 16,
                                                    ),
                                                    decoration:
                                                        const InputDecoration(
                                                          filled: false,
                                                          isDense: true,
                                                          border:
                                                              InputBorder.none,
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Phone Number Label
                                    Text(
                                      'phone_number'.tr,
                                      style: const TextStyle(
                                        color: Color(0xFF4A4A4A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Phone Number Input Container
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
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.02,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.phone_android_outlined,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            '+509',
                                            style: TextStyle(
                                              color: Color(0xFF2C2C2C),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors.grey.shade300,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Center(
                                              child: TextField(
                                                controller: authController
                                                    .signUpPhoneController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                style: const TextStyle(
                                                  color: AppTheme.textDark,
                                                  fontSize: 16,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                      filled: false,
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // Enter Password Label
                                    Text(
                                      'enter_password'.tr,
                                      style: const TextStyle(
                                        color: Color(0xFF4A4A4A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Password Input Container
                                    Obx(
                                      () => Container(
                                        height: 45,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.02,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: TextField(
                                                  controller: authController
                                                      .signUpPasswordController,
                                                  obscureText: !authController
                                                      .isSignUpPasswordVisible
                                                      .value,
                                                  style: const TextStyle(
                                                    color: AppTheme.textDark,
                                                    fontSize: 16,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        filled: false,
                                                        isDense: true,
                                                        border:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                authController
                                                        .isSignUpPasswordVisible
                                                        .value
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                              onPressed: authController
                                                  .toggleSignUpPasswordVisibility,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // Enter Confirm Password Label
                                    Text(
                                      'enter_confirm_password'.tr,
                                      style: const TextStyle(
                                        color: Color(0xFF4A4A4A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Confirm Password Input Container
                                    Obx(
                                      () => Container(
                                        height: 45,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.02,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: TextField(
                                                  controller: authController
                                                      .signUpConfirmPasswordController,
                                                  obscureText: !authController
                                                      .isSignUpConfirmPasswordVisible
                                                      .value,
                                                  style: const TextStyle(
                                                    color: AppTheme.textDark,
                                                    fontSize: 16,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        filled: false,
                                                        isDense: true,
                                                        border:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                authController
                                                        .isSignUpConfirmPasswordVisible
                                                        .value
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                              onPressed: authController
                                                  .toggleSignUpConfirmPasswordVisibility,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // Checkbox Terms Row
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(
                                          () => SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: authController
                                                  .isOver18Accepted
                                                  .value,
                                              onChanged: (val) {
                                                authController
                                                        .isOver18Accepted
                                                        .value =
                                                    val ?? false;
                                              },
                                              activeColor:
                                                  AppTheme.buttonOrange,
                                              checkColor: Colors.white,
                                              side: const BorderSide(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              authController
                                                  .isOver18Accepted
                                                  .value = !authController
                                                  .isOver18Accepted
                                                  .value;
                                            },
                                            child: _buildTermsText(),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    // Sign Up Button
                                    Obx(
                                      () => authController.isLoading.value
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppTheme.buttonOrange),
                                              ),
                                            )
                                          : SizedBox(
                                              width: double.infinity,
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  bool valid =
                                                      await authController
                                                          .register();
                                                  if (valid) {
                                                    authController
                                                        .startOtpTimer();
                                                    Get.to(
                                                      () => const OtpView(),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.buttonOrange,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          28,
                                                        ),
                                                  ),
                                                  elevation: 2,
                                                ),
                                                child: Text(
                                                  'sign_up'.tr.replaceAll(
                                                    ' !',
                                                    '',
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),

                                    const SizedBox(height: 15),

                                    // Footer Sign In Link
                                    Center(
                                      child: InkWell(
                                        onTap: () =>
                                            Get.off(() => const SignInView()),
                                        child: _buildSignInLink(),
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
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  // Language selector pill matching onboarding screen
  Widget _buildLanguageSelector(
    Size size,
    LocalizationController localizationController,
  ) {
    final boxW = size.width * (124.0 / 390.0);
    final boxH = size.height * (35.0 / 844.0);
    final radius = size.width * (45.0 / 390.0);

    return Container(
      width: boxW,
      height: boxH,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.primaryOrange, width: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            size: boxH * 0.55,
            color: AppTheme.primaryDarkBlue,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: DropdownButton<String>(
              value: localizationController.currentLanguage.value,
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: boxH * 0.55,
                color: AppTheme.primaryDarkBlue,
              ),
              style: TextStyle(
                color: AppTheme.primaryDarkBlue,
                fontWeight: FontWeight.w600,
                fontSize: boxH * 0.45,
              ),
              onChanged: (lang) {
                if (lang != null) localizationController.changeLanguage(lang);
              },
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'ht', child: Text('Kreyòl')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Close button matching onboarding screen
  Widget _buildCloseButton(Size size) {
    final btnSize = size.height * (35.0 / 844.0);
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Icon(
          Icons.close,
          color: Colors.grey.shade600,
          size: btnSize * 0.55,
        ),
      ),
    );
  }

  // Dynamic builder to split already_have_account.tr and highlight the action button
  Widget _buildSignInLink() {
    final translation = 'already_have_account'.tr;
    if (translation.contains('?')) {
      final parts = translation.split('?');
      final firstPart = '${parts[0]}?';
      final secondPart = parts.sublist(1).join('?').trim();
      return RichText(
        text: TextSpan(
          text: '$firstPart ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          children: [
            TextSpan(
              text: secondPart,
              style: const TextStyle(
                color: AppTheme.buttonOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        translation,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      );
    }
  }

  // Parses terms text to highlight 'Terms & Conditions' and 'Privacy Policy' in selected language
  Widget _buildTermsText() {
    final text = 'over_18_terms'.tr;
    final lang = Get.locale?.languageCode ?? 'en';

    String termsWord = 'Terms & Conditions';
    String privacyWord = 'Privacy Policy';

    if (lang == 'fr') {
      termsWord = 'Conditions Générales';
      privacyWord = 'Politique de Confidentialité';
    } else if (lang == 'ht') {
      termsWord = 'Kondisyon';
      privacyWord = 'Règleman sou Privasite';
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    while (lastIndex < text.length) {
      int termsIndex = text.indexOf(termsWord, lastIndex);
      int privacyIndex = text.indexOf(privacyWord, lastIndex);

      int nextHighlight = -1;
      String highlightWord = '';

      if (termsIndex != -1 && privacyIndex != -1) {
        if (termsIndex < privacyIndex) {
          nextHighlight = termsIndex;
          highlightWord = termsWord;
        } else {
          nextHighlight = privacyIndex;
          highlightWord = privacyWord;
        }
      } else if (termsIndex != -1) {
        nextHighlight = termsIndex;
        highlightWord = termsWord;
      } else if (privacyIndex != -1) {
        nextHighlight = privacyIndex;
        highlightWord = privacyWord;
      }

      if (nextHighlight == -1) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        );
        break;
      }

      if (nextHighlight > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, nextHighlight),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: highlightWord,
          style: const TextStyle(
            color: AppTheme.buttonOrange,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      );

      lastIndex = nextHighlight + highlightWord.length;
    }

    return RichText(text: TextSpan(children: spans));
  }
}
