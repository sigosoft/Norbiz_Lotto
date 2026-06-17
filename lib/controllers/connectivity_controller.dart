import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  var isConnected = true.obs;
  var isServerDown = false.obs;
  var isMaintenance = false.obs;
  var isUpdateRequired = false.obs;

  // The host of the backend server. The user can configure this (e.g. "api.norbizlotto.com").
  // If left as "google.com" or empty, it won't perform server down check by lookup.
  final String backendHost = "google.com";

  Timer? _timer;
  bool _isChecking = false;

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
        final internetResult = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (internetResult.isNotEmpty && internetResult[0].rawAddress.isNotEmpty) {
          generalConnectionOk = true;
        }
      } catch (_) {
        // Fallback check in case google.com is blocked/slow on this network
        try {
          final fallbackResult = await InternetAddress.lookup('cloudflare.com')
              .timeout(const Duration(seconds: 3));
          if (fallbackResult.isNotEmpty && fallbackResult[0].rawAddress.isNotEmpty) {
            generalConnectionOk = true;
          }
        } catch (_) {
          generalConnectionOk = false;
        }
      }

      if (generalConnectionOk) {
        isConnected.value = true;

        // 2. Check backend server connection if configured with a specific custom host
        if (backendHost.isNotEmpty && backendHost != "google.com") {
          try {
            final serverResult = await InternetAddress.lookup(backendHost)
                .timeout(const Duration(seconds: 3));
            if (serverResult.isNotEmpty && serverResult[0].rawAddress.isNotEmpty) {
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
        isConnected.value = false;
      }
    } catch (_) {
      isConnected.value = false;
    } finally {
      _isChecking = false;
    }
  }
}
