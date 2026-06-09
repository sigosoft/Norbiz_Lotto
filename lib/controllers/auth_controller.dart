import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../configs/toast.dart';

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

  // Reset Password controller
  final resetPhoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newConfirmPasswordController = TextEditingController();
  var isNewPasswordVisible = false.obs;
  var isNewConfirmPasswordVisible = false.obs;

  // OTP controller
  final otpControllers = List.generate(4, (_) => TextEditingController());
  final otpFocusNodes = List.generate(4, (_) => FocusNode());
  var otpCountdown = 60.obs;
  Timer? _otpTimer;

  // Mock profile data
  var userName = 'John Doe'.obs;
  final userPhone = '+1 (555) 012-3456'.obs;
  var userEmail = 'john.doe@example.com'.obs;
  var userGender = 'Male'.obs;
  var userDob = '1990-01-01'.obs;
  var userWalletBalance = 500.00.obs;

  void toggleSignInPasswordVisibility() {
    isSignInPasswordVisible.value = !isSignInPasswordVisible.value;
  }

  void toggleSignUpPasswordVisibility() {
    isSignUpPasswordVisible.value = !isSignUpPasswordVisible.value;
  }

  void toggleSignUpConfirmPasswordVisibility() {
    isSignUpConfirmPasswordVisible.value = !isSignUpConfirmPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleNewConfirmPasswordVisibility() {
    isNewConfirmPasswordVisible.value = !isNewConfirmPasswordVisible.value;
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
  Future<bool> login() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock network delay
    isLoading.value = false;
    userName.value = 'John Doe';
    return true;
  }

  Future<bool> register() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    userName.value = '${signUpFirstNameController.text} ${signUpLastNameController.text}';
    return true;
  }

  Future<bool> requestPasswordReset() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    return true;
  }

  Future<bool> verifyOtp() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    return true;
  }

  void updateProfile(String first, String last, String phone, String email, String gender, String dob) {
    userName.value = '$first $last';
    userPhone.value = phone;
    userEmail.value = email;
    userGender.value = gender;
    userDob.value = dob;
  }

  Future<bool> confirmPasswordReset() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    newPasswordController.clear();
    newConfirmPasswordController.clear();
    return true;
  }
}
