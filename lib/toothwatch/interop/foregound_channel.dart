import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:optional/optional.dart';
import 'package:toothwatch/toothwatch/notification/notification_init_state.dart';

class ForegroundChannel {
  static const MethodChannel platform = MethodChannel("com.example.toothwatch/timer");

  Future<void> startTimerService({@required NotificationInitState initialState}) async {
    await platform.invokeMethod<void>('startTimerService', <String, dynamic>{
      "stateJson": jsonEncode(initialState.toJson())
    });
  }

  Future<Optional<NotificationInitState>> getTimerStateAndClose() async {
    String timerStateJSON = await platform.invokeMethod<String>('getTimerStateAndClose');
    if (timerStateJSON == null)
      return Optional.empty();
    else
      return Optional.of(NotificationInitState.fromJson(jsonDecode(timerStateJSON)));
  }
}