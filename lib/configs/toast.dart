import 'package:flutter/material.dart';
import 'package:get/get.dart';

String formatErrorMessage(dynamic message) {
  if (message == null) return '';

  // If it's a String, check if it represents a Dart map/list or json
  if (message is String) {
    final trimmed = message.trim();
    // If it looks like a Dart map format, e.g., "{key: [val], key_fr: [val]}"
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      final lang = Get.locale?.languageCode ?? 'en';
      // Find the appropriate key matching the selected language
      if (lang == 'fr' && trimmed.contains('_fr:')) {
        final match = RegExp(r'_fr:\s*\[?([^\]\},]+)').firstMatch(trimmed);
        if (match != null) return match.group(1)?.trim() ?? '';
      } else if (lang == 'ht' && trimmed.contains('_ht:')) {
        final match = RegExp(r'_ht:\s*\[?([^\]\},]+)').firstMatch(trimmed);
        if (match != null) return match.group(1)?.trim() ?? '';
      }
      // Fallback: extract the first non-localized key's value
      final match = RegExp(r'^\w+:\s*\[?([^\]\},]+)').firstMatch(trimmed.substring(1));
      if (match != null) return match.group(1)?.trim() ?? '';
    }
    
    // Regular string cleanup
    String cleanMsg = trimmed
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('(', '')
        .replaceAll(')', '');
    cleanMsg = cleanMsg.replaceFirst(RegExp(r'^\w+:\s*'), '');
    return cleanMsg.trim();
  }

  final lang = Get.locale?.languageCode ?? 'en';

  if (message is Map) {
    dynamic selectedValue;

    if (lang == 'fr') {
      for (var entry in message.entries) {
        if (entry.key.toString().endsWith('_fr')) {
          selectedValue = entry.value;
          break;
        }
      }
    } else if (lang == 'ht') {
      for (var entry in message.entries) {
        if (entry.key.toString().endsWith('_ht')) {
          selectedValue = entry.value;
          break;
        }
      }
    }

    if (selectedValue == null) {
      for (var entry in message.entries) {
        final keyStr = entry.key.toString();
        if (!keyStr.endsWith('_fr') && !keyStr.endsWith('_ht')) {
          selectedValue = entry.value;
          break;
        }
      }
    }

    if (selectedValue == null && message.isNotEmpty) {
      selectedValue = message.values.first;
    }

    return formatErrorMessage(selectedValue);
  }

  if (message is List) {
    if (message.isEmpty) return '';
    return formatErrorMessage(message.first);
  }

  return message.toString();
}

void showToast(dynamic message, {String? title}) {
  String cleanMsg = formatErrorMessage(message);
  final String text =
      (title != null &&
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
      ? '$title: $cleanMsg'
      : cleanMsg;

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
