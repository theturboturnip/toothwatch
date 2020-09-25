import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:toothwatch/toothwatch/util/duration_utils.dart';

part 'persistent_notification_state.g.dart';

@JsonSerializable()
class PersistentNotificationState {
  final int timerStartEpochMs;
  final double previousSumTimes;
  final double expectedTotalTimeSeconds;

  const PersistentNotificationState({@required this.timerStartEpochMs, @required this.previousSumTimes, @required this.expectedTotalTimeSeconds});

  factory PersistentNotificationState.fromJson(Map<String, dynamic> json) => _$PersistentNotificationStateFromJson(json);
  Map<String, dynamic> toJson() => _$PersistentNotificationStateToJson(this);

  double secondsSinceInit() {
    return secondsSince(timerStartEpochMs);
  }
  double totalSecondsRemaining() {
    return expectedTotalTimeSeconds - secondsSinceInit() - previousSumTimes;
  }
}

@JsonSerializable()
class NotificationText {
  final String title;
  final String subtitle;

  const NotificationText({@required this.title, this.subtitle});

  factory NotificationText.fromJson(Map<String, dynamic> json) => _$NotificationTextFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationTextToJson(this);
}

double computeNotificationTimerSeconds(String notificationInitStateJson) {
  Map initStateMap = jsonDecode(notificationInitStateJson);
  final initState = PersistentNotificationState.fromJson(initStateMap);

  return initState.secondsSinceInit();
}

NotificationText computeNewNotificationText(String notificationInitStateJson) {
  Map initStateMap = jsonDecode(notificationInitStateJson);
  final initState = PersistentNotificationState.fromJson(initStateMap);
  final timeRemaining = durationFromPartialSeconds(seconds: initState.totalSecondsRemaining());
  final timeSinceInit = durationFromPartialSeconds(seconds: initState.secondsSinceInit());

  return NotificationText(
    title: remainingDurationToStringPretty(timeRemaining),
    subtitle: "Current session: ${durationToStringPretty(timeSinceInit)}"
  );
}
