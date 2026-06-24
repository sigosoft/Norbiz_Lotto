import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static final Map<String, Map<String, String>> _translations = {};

  static Future<void> loadTranslations() async {
    try {
      final enContent = await rootBundle.loadString('lib/l10n/intl_en.arb');
      final frContent = await rootBundle.loadString('lib/l10n/intl_fr.arb');
      final htContent = await rootBundle.loadString('lib/l10n/intl_ht.arb');

      _translations['en'] = Map<String, String>.from(jsonDecode(enContent));
      _translations['fr'] = Map<String, String>.from(jsonDecode(frContent));
      _translations['ht'] = Map<String, String>.from(jsonDecode(htContent));
      
      debugPrint('Translations loaded successfully from ARB files.');
    } catch (e) {
      debugPrint('Error loading translations from ARB assets: $e');
      // Fallbacks in case assets fail to load
      _translations['en'] = {};
      _translations['fr'] = {};
      _translations['ht'] = {};
    }
  }

  @override
  Map<String, Map<String, String>> get keys => _translations;
}
