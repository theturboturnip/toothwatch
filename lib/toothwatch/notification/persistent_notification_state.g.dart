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

PersistentNotificationEvalData _$PersistentNotificationEvalDataFromJson(
    Map<String, dynamic> json) {
  return PersistentNotificationEvalData(
    newPersistentStateJSONStr: json['newPersistentStateJSONStr'] as String,
    persistentNotificationText: json['persistentNotificationText'] == null
        ? null
        : NotificationText.fromJson(
            json['persistentNotificationText'] as Map<String, dynamic>),
    alertNotificationText: json['alertNotificationText'] == null
        ? null
        : NotificationText.fromJson(
            json['alertNotificationText'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PersistentNotificationEvalDataToJson(
        PersistentNotificationEvalData instance) =>
    <String, dynamic>{
      'newPersistentStateJSONStr': instance.newPersistentStateJSONStr,
      'persistentNotificationText':
          instance.persistentNotificationText?.toJson(),
      'alertNotificationText': instance.alertNotificationText?.toJson(),
    };
