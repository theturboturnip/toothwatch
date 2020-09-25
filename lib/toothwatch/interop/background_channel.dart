import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:toothwatch/toothwatch/notification/persistent_notification.dart';
import 'package:toothwatch/toothwatch/notification/persistent_notification_state.dart';

void backgroundChannel() {
  const MethodChannel _background = MethodChannel(
      "com.example.toothwatch/timer_background");

  WidgetsFlutterBinding.ensureInitialized();

  _background.setMethodCallHandler((MethodCall call) async {
    if (call.method == "getNotificationJSON") {
      return _getNotificationJson(call.arguments as String);
    } else {
      throw MissingPluginException("Method ${call.method} is not supported");
    }
  });
}

Map<String, dynamic> _getNotificationJson(String notificationInitStateJson) {
  final evalData = evalPersistentNotification(PersistentNotificationState.fromJsonStr(notificationInitStateJson));
  return evalData.toJson();
}