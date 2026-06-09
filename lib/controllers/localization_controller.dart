import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationController extends GetxController {
  var currentLanguage = 'en'.obs;
  var isRtl = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Default system locale check or English
    Locale? deviceLocale = Get.deviceLocale;
    if (deviceLocale != null) {
      String code = deviceLocale.languageCode;
      if (code == 'fr' || code == 'ht') {
        currentLanguage.value = code;
      }
    }
    updateLocale(currentLanguage.value);
  }

  void changeLanguage(String langCode) {
    currentLanguage.value = langCode;
    updateLocale(langCode);
  }

  void updateLocale(String langCode) {
    Locale locale;
    if (langCode == 'fr') {
      locale = const Locale('fr', 'FR');
      isRtl.value = false;
    } else if (langCode == 'ht') {
      locale = const Locale('ht', 'HT');
      isRtl.value = false;
    } else {
      locale = const Locale('en', 'US');
      isRtl.value = false; // Add RTL language overrides here if necessary
    }
    Get.updateLocale(locale);
  }

  TextDirection get textDirection => isRtl.value ? TextDirection.rtl : TextDirection.ltr;
}
