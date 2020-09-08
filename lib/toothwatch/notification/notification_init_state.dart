import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:toothwatch/toothwatch/util/duration_utils.dart';

part 'notification_init_state.g.dart';

@JsonSerializable()
class NotificationInitState {
  final double secondsElapsedAtStart;
  final int millisecondsEpochAtStart;

  const NotificationInitState({@required this.secondsElapsedAtStart, @required this.millisecondsEpochAtStart});

  factory NotificationInitState.fromJson(Map<String, dynamic> json) => _$NotificationInitStateFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationInitStateToJson(this);

  double secondsSinceInit() {
    return secondsElapsedAtStart + (DateTime.now().millisecondsSinceEpoch - millisecondsEpochAtStart) / 1000.0;
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
  double timerSeconds = computeNotificationTimerSeconds(notificationInitStateJson);

  return NotificationText(
    title: durationToStringPretty(durationFromPartialSeconds(seconds: timerSeconds))
  );
}
