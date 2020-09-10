import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:toothwatch/toothwatch/util/duration_utils.dart';

part 'notification_init_state.g.dart';

@JsonSerializable()
class NotificationInitState {
  final double timerSecondsElapsedAtStart;
  final int timerMillisecondsEpochAtStart;
  final double previousSumTimes;
  final double expectedTotalTimeSeconds;

  const NotificationInitState({@required this.timerSecondsElapsedAtStart, @required this.timerMillisecondsEpochAtStart, @required this.previousSumTimes, @required this.expectedTotalTimeSeconds});

  factory NotificationInitState.fromJson(Map<String, dynamic> json) => _$NotificationInitStateFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationInitStateToJson(this);

  double secondsSinceInit() {
    return timerSecondsElapsedAtStart + (DateTime.now().millisecondsSinceEpoch - timerMillisecondsEpochAtStart) / 1000.0;
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
  final initState = NotificationInitState.fromJson(initStateMap);

  return initState.secondsSinceInit();
}

NotificationText computeNewNotificationText(String notificationInitStateJson) {
  Map initStateMap = jsonDecode(notificationInitStateJson);
  final initState = NotificationInitState.fromJson(initStateMap);
  final timeRemaining = durationFromPartialSeconds(seconds: initState.totalSecondsRemaining());
  final timeSinceInit = durationFromPartialSeconds(seconds: initState.secondsSinceInit());

  return NotificationText(
    title: remainingDurationToStringPretty(timeRemaining),
    subtitle: "Current session: ${durationToStringPretty(timeSinceInit)}"
  );
}
