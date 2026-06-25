import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../configs/api_config.dart';
import 'localization_controller.dart';

class ConnectivityController extends GetxController {
  DateTime? _lastGeneralCheckTime;
  var isConnected = true.obs;
  var isServerDown = false.obs;
  var isMaintenance = false.obs;
  var isUpdateRequired = false.obs;
  var serverDownReason = ''.obs;

  // The host of the backend server. The user can configure this (e.g. "api.norbizlotto.com").
  // If left as "google.com" or empty, it won't perform server down check by lookup.
  final String backendHost = "google.com";

  Timer? _timer;
  bool _isChecking = false;
  int _failedCount = 0;

  @override
  void onInit() {
    super.onInit();
    checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      checkConnection();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> checkConnection() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      // 1. Check general internet connection with fallback
      bool generalConnectionOk = false;
      try {
        final internetResult = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 2));
        if (internetResult.isNotEmpty &&
            internetResult[0].rawAddress.isNotEmpty) {
          generalConnectionOk = true;
        }
      } catch (_) {
        // Fallback check in case google.com is blocked/slow on this network
        try {
          final fallbackResult = await InternetAddress.lookup(
            'cloudflare.com',
          ).timeout(const Duration(seconds: 2));
          if (fallbackResult.isNotEmpty &&
              fallbackResult[0].rawAddress.isNotEmpty) {
            generalConnectionOk = true;
          }
        } catch (_) {
          generalConnectionOk = false;
        }
      }

      if (generalConnectionOk) {
        _failedCount = 0;
        isConnected.value = true;

        // Fetch maintenance/updates status from general API (max once every 30 seconds)
        final now = DateTime.now();
        if (_lastGeneralCheckTime == null ||
            now.difference(_lastGeneralCheckTime!).inSeconds >= 30) {
          _lastGeneralCheckTime = now;
          // Run check in background so it doesn't block local ping latency checks
          checkMaintenanceAndUpdates();
        }

        // 2. Check backend server connection if configured with a specific custom host
        if (backendHost.isNotEmpty && backendHost != "google.com") {
          try {
            final serverResult = await InternetAddress.lookup(
              backendHost,
            ).timeout(const Duration(seconds: 2));
            if (serverResult.isNotEmpty &&
                serverResult[0].rawAddress.isNotEmpty) {
              isServerDown.value = false;
            } else {
              isServerDown.value = true;
            }
          } catch (_) {
            isServerDown.value = true;
          }
        } else {
          // If not configured, default to not down
          isServerDown.value = false;
        }
      } else {
        _failedCount++;
        if (_failedCount >= 3) {
          isConnected.value = false;
        }
      }
    } catch (_) {
      _failedCount++;
      if (_failedCount >= 3) {
        isConnected.value = false;
      }
    } finally {
      _isChecking = false;
    }
  }

  Future<void> checkMaintenanceAndUpdates() async {
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 10);

      final String url = '${ApiConfig.baseUrl}${ApiConfig.general}';
      debugPrint('=== CONNECTIVITY CHECK: GENERAL API CALL ===');
      debugPrint('URL: $url');

      final response = await connect.get(url);
      debugPrint('=== CONNECTIVITY CHECK: GENERAL API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.body != null) {
        isServerDown.value = false;
        final resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          return;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true) {
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};

          final general = data['general'] != null
              ? Map<String, dynamic>.from(data['general'])
              : <String, dynamic>{};

          final String versionAndroid =
              general['version_android']?.toString() ?? '1.0.0';
          final String versionIos =
              general['version_ios']?.toString() ?? '1.0.0';
          final bool forceUpdateAndroid =
              (general['force_update_android'] == 1 ||
              general['force_update_android'] == '1');
          final bool forceUpdateIos =
              (general['force_update_ios'] == 1 ||
              general['force_update_ios'] == '1');
          final bool maintenanceAndroid =
              (general['maintenance_android'] == 1 ||
              general['maintenance_android'] == '1');
          final bool maintenanceIos =
              (general['maintenance_ios'] == 1 ||
              general['maintenance_ios'] == '1');

          bool maintenanceActive = false;
          bool updateRequiredActive = false;

          if (Platform.isAndroid) {
            maintenanceActive = maintenanceAndroid;
            const String currentVersion = '2.8.1';
            bool newerAvailable = false;
            try {
              final apiParts = versionAndroid
                  .split('.')
                  .map((e) => int.tryParse(e) ?? 0)
                  .toList();
              final currParts = currentVersion
                  .split('.')
                  .map((e) => int.tryParse(e) ?? 0)
                  .toList();
              for (int i = 0; i < apiParts.length; i++) {
                int currVal = i < currParts.length ? currParts[i] : 0;
                if (apiParts[i] > currVal) {
                  newerAvailable = true;
                  break;
                } else if (apiParts[i] < currVal) {
                  break;
                }
              }
            } catch (_) {}
            updateRequiredActive = forceUpdateAndroid && newerAvailable;
          } else if (Platform.isIOS) {
            maintenanceActive = maintenanceIos;
            const String currentVersion = '2.8.1';
            bool newerAvailable = false;
            try {
              final apiParts = versionIos
                  .split('.')
                  .map((e) => int.tryParse(e) ?? 0)
                  .toList();
              final currParts = currentVersion
                  .split('.')
                  .map((e) => int.tryParse(e) ?? 0)
                  .toList();
              for (int i = 0; i < apiParts.length; i++) {
                int currVal = i < currParts.length ? currParts[i] : 0;
                if (apiParts[i] > currVal) {
                  newerAvailable = true;
                  break;
                } else if (apiParts[i] < currVal) {
                  break;
                }
              }
            } catch (_) {}
            updateRequiredActive = forceUpdateIos && newerAvailable;
          }

          // Extract localized maintenance reason if available
          String reason = '';
          try {
            final String lang = Get.find<LocalizationController>().currentLanguage.value;
            reason = general['maintenance_message_$lang']?.toString() ?? 
                     general['maintenance_message']?.toString() ?? 
                     general['maintenance_text']?.toString() ?? 
                     general['server_down_reason']?.toString() ?? 
                     '';
          } catch (_) {
            reason = general['maintenance_message']?.toString() ?? 
                     general['maintenance_text']?.toString() ?? 
                     general['server_down_reason']?.toString() ?? 
                     '';
          }
          serverDownReason.value = reason;

          isMaintenance.value = maintenanceActive;
          isUpdateRequired.value = updateRequiredActive;
        }
      }
    } catch (e) {
      debugPrint('Error checking maintenance and updates: $e');
    }
  }
}
