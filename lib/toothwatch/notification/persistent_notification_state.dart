import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:toothwatch/toothwatch/models/stopwatch_persistent_state.dart';
import 'package:toothwatch/toothwatch/util/duration_utils.dart';

import 'notification_text.dart';

part 'persistent_notification_state.g.dart';

@JsonSerializable()
class PersistentNotificationState {
  final int timerStartEpochMs;
  final double sumTimes;
  final double expectedTotalTimeSeconds;
  final double previousSecondsSinceInit;

  const PersistentNotificationState({@required this.timerStartEpochMs, @required this.sumTimes, @required this.expectedTotalTimeSeconds, @required this.previousSecondsSinceInit});
  factory PersistentNotificationState.fromStopwatchState(StopwatchPersistentState state) {
    assert(state.timerStartEpochMs != null);
    return PersistentNotificationState(
        timerStartEpochMs: state.timerStartEpochMs,
        sumTimes: state.timingData.sumTimes,
        expectedTotalTimeSeconds: state.timingData.expectedTotalTimeSeconds,
        previousSecondsSinceInit: secondsSince(state.timerStartEpochMs)
    );
  }

  PersistentNotificationState withNewPreviousState(double previousSecondsSinceInit) {
    return PersistentNotificationState(
        timerStartEpochMs: this.timerStartEpochMs,
        sumTimes: this.sumTimes,
        expectedTotalTimeSeconds: this.expectedTotalTimeSeconds,
        previousSecondsSinceInit: previousSecondsSinceInit
    );
  }

  factory PersistentNotificationState.fromJsonStr(String jsonStr) => PersistentNotificationState.fromJson(jsonDecode(jsonStr));
  factory PersistentNotificationState.fromJson(Map<String, dynamic> json) => _$PersistentNotificationStateFromJson(json);
  Map<String, dynamic> toJson() => _$PersistentNotificationStateToJson(this);
  String toJsonStr() => jsonEncode(toJson());

  double secondsSinceInit() {
    return secondsSince(timerStartEpochMs);
  }
  double totalSecondsRemaining() {
    return expectedTotalTimeSeconds - secondsSinceInit() - sumTimes;
  }
}

@JsonSerializable(explicitToJson: true)
class PersistentNotificationEvalData {
  final String newPersistentStateJSONStr;
  final NotificationText persistentNotificationText;
  @JsonKey(includeIfNull: true)
  final NotificationText alertNotificationText;
  final int nextNotificationDelayMillis;

  const PersistentNotificationEvalData({@required this.newPersistentStateJSONStr, @required this.persistentNotificationText, @required this.alertNotificationText, @required this.nextNotificationDelayMillis});
  PersistentNotificationEvalData.fromState(PersistentNotificationState state, {@required this.persistentNotificationText, @required this.alertNotificationText, @required this.nextNotificationDelayMillis}) :
        assert(state != null),
        assert(persistentNotificationText != null),
        this.newPersistentStateJSONStr = state.toJsonStr();

  factory PersistentNotificationEvalData.fromJsonStr(String jsonStr) => PersistentNotificationEvalData.fromJson(jsonDecode(jsonStr));
  factory PersistentNotificationEvalData.fromJson(Map<String, dynamic> json) => _$PersistentNotificationEvalDataFromJson(json);
  Map<String, dynamic> toJson() => _$PersistentNotificationEvalDataToJson(this);
  String toJsonStr() => jsonEncode(toJson());
}
