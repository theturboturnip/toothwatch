// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistent_notification_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersistentNotificationState _$PersistentNotificationStateFromJson(
    Map<String, dynamic> json) {
  return PersistentNotificationState(
    timerSecondsElapsedAtStart:
        (json['timerSecondsElapsedAtStart'] as num)?.toDouble(),
    timerMillisecondsEpochAtStart: json['timerMillisecondsEpochAtStart'] as int,
    previousSumTimes: (json['previousSumTimes'] as num)?.toDouble(),
    expectedTotalTimeSeconds:
        (json['expectedTotalTimeSeconds'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$PersistentNotificationStateToJson(
        PersistentNotificationState instance) =>
    <String, dynamic>{
      'timerSecondsElapsedAtStart': instance.timerSecondsElapsedAtStart,
      'timerMillisecondsEpochAtStart': instance.timerMillisecondsEpochAtStart,
      'previousSumTimes': instance.previousSumTimes,
      'expectedTotalTimeSeconds': instance.expectedTotalTimeSeconds,
    };

NotificationText _$NotificationTextFromJson(Map<String, dynamic> json) {
  return NotificationText(
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
  );
}

Map<String, dynamic> _$NotificationTextToJson(NotificationText instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
    };
