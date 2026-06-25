import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../configs/api_config.dart';
import '../configs/toast.dart';
import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  var notificationsList = <NotificationModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
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

      final String url = '${ApiConfig.baseUrl}${ApiConfig.notifications}';

      debugPrint('=== FETCH NOTIFICATIONS API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      final response = await connect.get(url, headers: headers);

      debugPrint('=== FETCH NOTIFICATIONS RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        final resData = response.body;
        Map<String, dynamic> dataMap;
        if (resData is String) {
          dataMap = Map<String, dynamic>.from(jsonDecode(resData));
        } else if (resData is Map) {
          dataMap = Map<String, dynamic>.from(resData);
        } else {
          showToast('Failed to parse response.'.tr, title: 'Error'.tr);
          isLoading.value = false;
          return;
        }

        if (dataMap['status'] == 'true' || dataMap['status'] == true || dataMap['status'] == 'success') {
          final data = dataMap['data'] != null
              ? Map<String, dynamic>.from(dataMap['data'])
              : <String, dynamic>{};
          final notificationsObj = data['notifications'] != null
              ? Map<String, dynamic>.from(data['notifications'])
              : <String, dynamic>{};
          final rawList = notificationsObj['data'] != null
              ? List<dynamic>.from(notificationsObj['data'])
              : [];

          final List<NotificationModel> loadedList = [];
          for (var item in rawList) {
            if (item is Map) {
              loadedList.add(NotificationModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }

          notificationsList.value = loadedList;
        } else {
          showToast(
            dataMap['message']?.toString() ?? 'Failed to load notifications.'.tr,
            title: 'Error'.tr,
          );
        }
      } else {
        showToast(
          'Failed to connect to the server.'.tr,
          title: 'Error'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      showToast(
        'An error occurred while loading notifications.'.tr,
        title: 'Error'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
