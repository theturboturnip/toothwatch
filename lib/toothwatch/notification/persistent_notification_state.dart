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

  factory PersistentNotificationState.fromJsonStr(String jsonStr) => PersistentNotificationState.fromJson(jsonDecode(jsonStr));
  factory PersistentNotificationState.fromJson(Map<String, dynamic> json) => _$PersistentNotificationStateFromJson(json);
  Map<String, dynamic> toJson() => _$PersistentNotificationStateToJson(this);

  double secondsSinceInit() {
    return secondsSince(timerStartEpochMs);
  }
  double totalSecondsRemaining() {
    return expectedTotalTimeSeconds - secondsSinceInit() - previousSumTimes;
  }
}


