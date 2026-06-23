import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:norbiz_loto/views/auth/signin_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_controller.dart';
import '../configs/toast.dart';
import '../configs/api_config.dart';

class AuthController extends GetxController {
  // Common states
  var isLoading = false.obs;

  // Sign In controllers
  final signInPhoneController = TextEditingController();
  final signInPasswordController = TextEditingController();
  var isSignInPasswordVisible = false.obs;

  // Sign Up controllers
  final signUpFirstNameController = TextEditingController();
  final signUpLastNameController = TextEditingController();
  final signUpPhoneController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpConfirmPasswordController = TextEditingController();
  var isSignUpPasswordVisible = false.obs;
  var isSignUpConfirmPasswordVisible = false.obs;
  var isOver18Accepted = false.obs;

  // Country Code integration variables
  var countryCodesList = <dynamic>[].obs;
  var selectedCountryDialCode = "+509".obs;
  var selectedCountryId = "5".obs;
  var isFetchingCountryCodes = false.obs;

  // Reset Password controller
  final resetPhoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newConfirmPasswordController = TextEditingController();
  var isNewPasswordVisible = false.obs;
  var isNewConfirmPasswordVisible = false.obs;

  // OTP controller
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  var otpCountdown = 60.obs;
  Timer? _otpTimer;

  // Mock profile data
  var userName = 'John Doe'.obs;
  final userPhone = '+1 (555) 012-3456'.obs;
  var userEmail = 'john.doe@example.com'.obs;
  var userGender = 'Male'.obs;
  var userDob = '1990-01-01'.obs;
  var userWalletBalance = 500.00.obs;
  var userImageUrl = ''.obs;
  var selectedImagePath = ''.obs;
  var userMobileRaw = ''.obs;

  void toggleSignInPasswordVisibility() {
    isSignInPasswordVisible.value = !isSignInPasswordVisible.value;
  }

  void toggleSignUpPasswordVisibility() {
    isSignUpPasswordVisible.value = !isSignUpPasswordVisible.value;
  }

  void toggleSignUpConfirmPasswordVisibility() {
    isSignUpConfirmPasswordVisible.value =
        !isSignUpConfirmPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
    debugPrint(
      "New Password visibility toggled to: ${isNewPasswordVisible.value}",
    );
  }

  void toggleNewConfirmPasswordVisibility() {
    isNewConfirmPasswordVisible.value = !isNewConfirmPasswordVisible.value;
    debugPrint(
      "Confirm Password visibility toggled to: ${isNewConfirmPasswordVisible.value}",
    );
  }

  // OTP Timer countdown
  void startOtpTimer() {
    otpCountdown.value = 60;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpCountdown.value > 0) {
        otpCountdown.value--;
      } else {
        _otpTimer?.cancel();
      }
    });
  }

  void resendOtp() {
    startOtpTimer();
    showToast('Verification code resent successfully.'.tr, title: 'Success');
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    signInPhoneController.dispose();
    signInPasswordController.dispose();
    signUpFirstNameController.dispose();
    signUpLastNameController.dispose();
    signUpPhoneController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    resetPhoneController.dispose();
    newPasswordController.dispose();
    newConfirmPasswordController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }

  // Mock Authentication APIs
  bool validateSignInForm() {
    if (signInPhoneController.text.trim().isEmpty) {
      showToast('Please enter your phone number.'.tr, title: 'Error');
      return false;
    }
    if (signInPasswordController.text.isEmpty) {
      showToast('Please enter your password.'.tr, title: 'Error');
      return false;
    }
    return true;
  }

  Future<bool> login() async {
    isLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final Map<String, dynamic> body = {
        'country_code_id': selectedCountryId.value,
        'mobile': signInPhoneController.text.trim(),
        'password': signInPasswordController.text,
      };

      final String url = '${ApiConfig.baseUrl}${ApiConfig.login}';
      debugPrint('=== API CALL REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Request Body: $body');

      final response = await connect.post(url, FormData(body));

      debugPrint('=== API CALL RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null &&
            (data['status'] == 'true' || data['status'] == true)) {
          final details = data['data'] != null ? data['data']['details'] : null;
          if (details != null) {
            userName.value = details['name'] ?? 'John Doe';
            userPhone.value = details['mobile'] ?? signInPhoneController.text;
            userEmail.value = details['email'] ?? '';
            userMobileRaw.value = details['mobile']?.toString() ?? signInPhoneController.text;

            final String? token = details['token'];
            debugPrint('Authentication Token: $token');
            await saveSession(Map<String, dynamic>.from(details));
          }
          return true;
        } else {
          final dynamic errMsg = data != null && data['message'] != null
              ? data['message']
              : 'Login failed. Please check your credentials.';
          showToast(errMsg, title: 'Error');
          return false;
        }
      } else {
        final data = response.body;
        final dynamic errMsg = data != null && data['message'] != null
            ? data['message']
            : 'Server error. Please try again later.';
        showToast(errMsg, title: 'Error');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      showToast('Connection error: $e', title: 'Error');
      return false;
    }
  }

  bool validateSignUpForm() {
    if (signUpFirstNameController.text.trim().isEmpty) {
      showToast('Please enter your first name.'.tr, title: 'Error');
      return false;
    }
    if (signUpLastNameController.text.trim().isEmpty) {
      showToast('Please enter your last name.'.tr, title: 'Error');
      return false;
    }
    if (signUpPhoneController.text.trim().isEmpty) {
      showToast('Please enter your phone number.'.tr, title: 'Error');
      return false;
    }
    if (signUpPhoneController.text.trim().length < 8) {
      showToast('Please enter a valid phone number.'.tr, title: 'Error');
      return false;
    }
    if (signUpPasswordController.text.isEmpty) {
      showToast('Please enter your password.'.tr, title: 'Error');
      return false;
    }
    if (signUpPasswordController.text.length < 6) {
      showToast('Password must be at least 6 characters.'.tr, title: 'Error');
      return false;
    }
    if (signUpConfirmPasswordController.text.isEmpty) {
      showToast('Please confirm your password.'.tr, title: 'Error');
      return false;
    }
    if (signUpPasswordController.text != signUpConfirmPasswordController.text) {
      showToast('Passwords do not match.'.tr, title: 'Error');
      return false;
    }
    if (!isOver18Accepted.value) {
      showToast('You must accept the Terms and Conditions.'.tr, title: 'Error');
      return false;
    }
    return true;
  }

  Future<bool> register() async {
    isLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final Map<String, dynamic> body = {
        'first_name': signUpFirstNameController.text.trim(),
        'last_name': signUpLastNameController.text.trim(),
        'country_code_id': selectedCountryId.value,
        'mobile': signUpPhoneController.text.trim(),
        'password': signUpPasswordController.text,
        'confirm_password': signUpConfirmPasswordController.text,
        'terms_accepted': isOver18Accepted.value ? '1' : '0',
      };

      final String url = '${ApiConfig.baseUrl}${ApiConfig.register}';
      debugPrint('=== API CALL REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Request Body: $body');

      final response = await connect.post(url, FormData(body));

      debugPrint('=== API CALL RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null &&
            (data['status'] == 'true' || data['status'] == true)) {
          final details = data['data'] != null ? data['data']['details'] : null;
          if (details != null) {
            userName.value =
                details['name'] ??
                '${signUpFirstNameController.text} ${signUpLastNameController.text}';
            userPhone.value = details['mobile'] ?? signUpPhoneController.text;
            userEmail.value = details['email'] ?? '';
            userMobileRaw.value = details['mobile']?.toString() ?? signUpPhoneController.text;

            final String? token = details['token'];
            debugPrint('Authentication Token: $token');
            await saveSession(Map<String, dynamic>.from(details));
          }
          return true;
        } else {
          final dynamic errMsg = data != null && data['message'] != null
              ? data['message']
              : 'Registration failed. Please check your details.';
          showToast(errMsg, title: 'Error');
          return false;
        }
      } else {
        final data = response.body;
        final dynamic errMsg = data != null && data['message'] != null
            ? data['message']
            : 'Server error. Please try again later.';
        showToast(errMsg, title: 'Error');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      showToast('Connection error: $e', title: 'Error');
      return false;
    }
  }

  bool validateResetPasswordForm() {
    if (resetPhoneController.text.trim().isEmpty) {
      showToast('Please enter your phone number.'.tr, title: 'Error');
      return false;
    }
    return true;
  }

  Future<bool> requestPasswordReset() async {
    isLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final Map<String, dynamic> body = {
        'country_code_id': selectedCountryId.value,
        'mobile': resetPhoneController.text.trim(),
      };

      final String url =
          '${ApiConfig.baseUrl}${ApiConfig.forgotPasswordSendOtp}';
      debugPrint('=== API CALL REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Request Body: $body');

      final response = await connect.post(url, FormData(body));

      debugPrint('=== API CALL RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null &&
            (data['status'] == 'true' || data['status'] == true)) {
          final dynamic successMsg =
              data['message'] ?? 'Verification code sent successfully.';
          showToast(successMsg, title: 'Success');
          return true;
        } else {
          final dynamic errMsg = data != null && data['message'] != null
              ? data['message']
              : 'Failed to send verification code.';
          showToast(errMsg, title: 'Error');
          return false;
        }
      } else {
        final data = response.body;
        final dynamic errMsg = data != null && data['message'] != null
            ? data['message']
            : 'Server error. Please try again later.';
        showToast(errMsg, title: 'Error');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      showToast('Connection error: $e', title: 'Error');
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    isLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final String mobile = resetPhoneController.text.trim().isNotEmpty
          ? resetPhoneController.text.trim()
          : signUpPhoneController.text.trim();

      final String otp = otpControllers.map((c) => c.text).join().trim();

      final Map<String, dynamic> body = {
        'country_code_id': selectedCountryId.value,
        'mobile': mobile,
        'otp': otp,
      };

      final String url =
          '${ApiConfig.baseUrl}${ApiConfig.forgotPasswordVerifyOtp}';
      debugPrint('=== API CALL REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Request Body: $body');

      final response = await connect.post(url, FormData(body));

      debugPrint('=== API CALL RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null &&
            (data['status'] == 'true' || data['status'] == true)) {
          final dynamic successMsg =
              data['message'] ?? 'Verification code verified successfully.';
          showToast(successMsg, title: 'Success');
          return true;
        } else {
          final dynamic errMsg = data != null && data['message'] != null
              ? data['message']
              : 'Failed to verify verification code.';
          showToast(errMsg, title: 'Error');
          return false;
        }
      } else {
        final data = response.body;
        final dynamic errMsg = data != null && data['message'] != null
            ? data['message']
            : 'Server error. Please try again later.';
        showToast(errMsg, title: 'Error');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      showToast('Connection error: $e', title: 'Error');
      return false;
    }
  }

  Future<bool> updateProfile(
    String first,
    String last,
    String phone,
    String email,
    String gender,
    String dob,
  ) async {
    isLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final Map<String, dynamic> body = {
        'first_name': first,
        'last_name': last,
        'gender': gender.toLowerCase().contains('female') ? '2' : '1',
        'date_of_birth': dob,
        'country_code_id': selectedCountryId.value,
        'mobile': phone,
        'email': email,
      };

      if (selectedImagePath.value.isNotEmpty) {
        final file = File(selectedImagePath.value);
        if (await file.exists()) {
          final fileBytes = await file.readAsBytes();
          body['image'] = MultipartFile(fileBytes, filename: 'avatar.png');
        }
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.updateProfile}';
      debugPrint('=== UPDATE PROFILE API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Token: $token');
      debugPrint('Headers: $headers');
      debugPrint('Body Fields: $body');

      final response = await connect.post(
        url,
        FormData(body),
        headers: headers,
      );

      debugPrint('=== UPDATE PROFILE RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isLoading.value = false;

      if (response.statusCode == 200 && response.body != null) {
        final dynamic resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          showToast('Unexpected response format.', title: 'Error');
          return false;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : {};
          final profile = data['profile'] != null
              ? Map<String, dynamic>.from(data['profile'])
              : {};

          if (profile.isNotEmpty) {
            final firstName = profile['first_name']?.toString() ?? '';
            final lastName = profile['last_name']?.toString() ?? '';
            userName.value = '$firstName $lastName'.trim();
            if (userName.value.isEmpty) {
              userName.value = 'John Doe';
            }

            userPhone.value =
                profile['phone_display']?.toString() ??
                profile['mobile']?.toString() ??
                '';
            userEmail.value = profile['email']?.toString() ?? '';
            userDob.value = profile['date_of_birth']?.toString() ?? '';
            userGender.value =
                profile['gender_label_en']?.toString() ??
                profile['gender']?.toString() ??
                '';
            userImageUrl.value = profile['image']?.toString() ?? '';
            userMobileRaw.value = profile['mobile']?.toString() ?? '';

            await prefs.setString('user_name', userName.value);
            await prefs.setString(
              'user_phone',
              profile['mobile']?.toString() ?? '',
            );
            await prefs.setString('user_email', userEmail.value);
          }

          selectedImagePath.value = '';
          return true;
        } else {
          final dynamic errMsg =
              dataMap['message'] ?? 'Failed to update profile.';
          showToast(errMsg.toString(), title: 'Error');
          return false;
        }
      } else {
        final dynamic resData = response.body;
        String errMsg = 'Server error. Please try again.';
        if (resData != null && resData is Map && resData['message'] != null) {
          errMsg = resData['message'].toString();
        }
        showToast(errMsg, title: 'Error');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      showToast('Connection error: $e', title: 'Error');
      return false;
    }
  }

  Future<void> fetchCountryCodes() async {
    isFetchingCountryCodes.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final String url = '${ApiConfig.baseUrl}${ApiConfig.countryCodes}';
      debugPrint('=== API CALL REQUEST ===');
      debugPrint('URL: $url');

      final response = await connect.get(url);

      debugPrint('=== API CALL RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isFetchingCountryCodes.value = false;

      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null &&
            (data['status'] == 'true' || data['status'] == true)) {
          final list = data['data'] as List<dynamic>? ?? [];
          countryCodesList.value = list;

          final currentDial = selectedCountryDialCode.value;
          final match = list.firstWhere(
            (item) => item['dial_code']?.toString() == currentDial,
            orElse: () => null,
          );
          if (match != null) {
            selectedCountryId.value = match['id']?.toString() ?? '5';
          }
        }
      }
    } catch (e) {
      isFetchingCountryCodes.value = false;
      debugPrint('Error fetching country codes: $e');
    }
  }

  void showCountryCodePicker(BuildContext context) {
    fetchCountryCodes();

    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Country Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Obx(() {
                  if (isFetchingCountryCodes.value &&
                      countryCodesList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFE9900),
                        ),
                      ),
                    );
                  }
                  if (countryCodesList.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'No country codes found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: countryCodesList.length,
                    itemBuilder: (context, index) {
                      final item = countryCodesList[index];
                      final name = item['country_name'] ?? '';
                      final dialCode = item['dial_code'] ?? '';
                      final id = item['id']?.toString() ?? '';
                      return ListTile(
                        title: Text('$name ($dialCode)'),
                        onTap: () {
                          selectedCountryDialCode.value = dialCode;
                          selectedCountryId.value = id;
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> saveSession(Map<String, dynamic> details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = details['name'] ?? '';
      final mobile = details['mobile'] ?? '';
      final email = details['email'] ?? '';
      final token = details['token'] ?? '';

      await prefs.setString('user_name', name);
      await prefs.setString('user_phone', mobile);
      await prefs.setString('user_email', email);
      await prefs.setString('auth_token', token);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      userName.value = 'John Doe';
      userPhone.value = '';
      userEmail.value = '';

      try {
        Get.find<HomeController>().currentNavIndex.value = 0;
      } catch (e) {
        debugPrint('Error resetting navigation index: $e');
      }

      Get.offAll(() => const SignInView());
    } catch (e) {
      debugPrint('Error logging out: $e');
      Get.offAll(() => const SignInView());
    }
  }

  Future<bool> confirmPasswordReset() async {
    final String password = newPasswordController.text;
    final String confirmPassword = newConfirmPasswordController.text;

    if (password.isEmpty) {
      showToast('Please enter your new password.'.tr, title: 'Error');
      return false;
    }
    if (password.length < 6) {
      showToast('Password must be at least 6 characters.'.tr, title: 'Error');
      return false;
    }
    if (confirmPassword.isEmpty) {
      showToast('Please confirm your new password.'.tr, title: 'Error');
      return false;
    }
    if (password != confirmPassword) {
      showToast('Passwords do not match.'.tr, title: 'Error');
      return false;
    }

    isLoading.value = true;
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final Map<String, dynamic> body = {
        'country_code_id': selectedCountryId.value,
        'mobile': resetPhoneController.text.trim(),
        'password': password,
        'confirm_password': confirmPassword,
      };

      final String url = '${ApiConfig.baseUrl}${ApiConfig.forgotPasswordReset}';
      debugPrint('=== API CALL REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Request Body: $body');

      final response = await connect.post(url, FormData(body));

      debugPrint('=== API CALL RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null &&
            (data['status'] == 'true' || data['status'] == true)) {
          final dynamic successMsg =
              data['message'] ?? 'Password reset successfully.';
          showToast(successMsg, title: 'Success');
          newPasswordController.clear();
          newConfirmPasswordController.clear();
          return true;
        } else {
          final dynamic errMsg = data != null && data['message'] != null
              ? data['message']
              : 'Failed to reset password.';
          showToast(errMsg, title: 'Error');
          return false;
        }
      } else {
        final data = response.body;
        final dynamic errMsg = data != null && data['message'] != null
            ? data['message']
            : 'Server error. Please try again later.';
        showToast(errMsg, title: 'Error');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      showToast('Connection error: $e', title: 'Error');
      return false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final String url = '${ApiConfig.baseUrl}${ApiConfig.profile}';
      debugPrint('=== FETCH PROFILE API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Token: $token');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH PROFILE RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        final dynamic resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          debugPrint('Unexpected response body type: ${resData.runtimeType}');
          return;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : {};
          final profile = data['profile'] != null
              ? Map<String, dynamic>.from(data['profile'])
              : {};

          if (profile.isNotEmpty) {
            final firstName = profile['first_name']?.toString() ?? '';
            final lastName = profile['last_name']?.toString() ?? '';
            userName.value = '$firstName $lastName'.trim();
            if (userName.value.isEmpty) {
              userName.value = 'John Doe';
            }

            userPhone.value =
                profile['phone_display']?.toString() ??
                profile['mobile']?.toString() ??
                '';
            userEmail.value = profile['email']?.toString() ?? '';
            userDob.value = profile['date_of_birth']?.toString() ?? '';
            userGender.value =
                profile['gender_label_en']?.toString() ??
                profile['gender']?.toString() ??
                '';
            userImageUrl.value = profile['image']?.toString() ?? '';
            userMobileRaw.value = profile['mobile']?.toString() ?? '';

            await prefs.setString('user_name', userName.value);
            await prefs.setString(
              'user_phone',
              profile['mobile']?.toString() ?? '',
            );
            await prefs.setString('user_email', userEmail.value);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }
}
