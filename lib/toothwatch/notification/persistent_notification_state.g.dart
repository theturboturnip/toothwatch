// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistent_notification_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersistentNotificationState _$PersistentNotificationStateFromJson(
    Map<String, dynamic> json) {
  return PersistentNotificationState(
    timerStartEpochMs: json['timerStartEpochMs'] as int,
    previousSumTimes: (json['previousSumTimes'] as num)?.toDouble(),
    expectedTotalTimeSeconds:
        (json['expectedTotalTimeSeconds'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$PersistentNotificationStateToJson(
        PersistentNotificationState instance) =>
    <String, dynamic>{
      'timerStartEpochMs': instance.timerStartEpochMs,
      'previousSumTimes': instance.previousSumTimes,
      'expectedTotalTimeSeconds': instance.expectedTotalTimeSeconds,
    };
