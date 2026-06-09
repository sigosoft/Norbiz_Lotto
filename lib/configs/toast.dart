import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showToast(String message, {String? title}) {
  final String text = (title != null && 
          title.isNotEmpty && 
          title != 'Success' && 
          title != 'Error' && 
          title != 'Deleted' && 
          title != 'Redirecting' &&
          title != 'Added to Cart' &&
          title != 'WhatsApp Support' &&
          title != 'Email Support' &&
          title != 'Deposit Successful' &&
          title != 'Withdrawal Processing')
      ? '$title: $message'
      : message;

  Get.rawSnackbar(
    messageText: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    backgroundColor: Colors.black.withOpacity(0.85),
    borderRadius: 24,
    margin: const EdgeInsets.only(bottom: 60, left: 48, right: 48),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    duration: const Duration(seconds: 2),
    snackPosition: SnackPosition.BOTTOM,
    isDismissible: true,
  );
}
