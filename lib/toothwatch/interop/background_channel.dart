import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:toothwatch/toothwatch/notification/notification_init_state.dart';

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
  final notificationText = computeNewNotificationText(notificationInitStateJson);
  return notificationText.toJson();
}