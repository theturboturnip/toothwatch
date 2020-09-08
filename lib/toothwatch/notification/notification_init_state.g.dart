// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_init_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationInitState _$NotificationInitStateFromJson(
    Map<String, dynamic> json) {
  return NotificationInitState(
    timerSecondsElapsedAtStart:
        (json['timerSecondsElapsedAtStart'] as num)?.toDouble(),
    timerMillisecondsEpochAtStart: json['timerMillisecondsEpochAtStart'] as int,
    previousSumTimes: (json['previousSumTimes'] as num)?.toDouble(),
    expectedTotalTimeSeconds:
        (json['expectedTotalTimeSeconds'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$NotificationInitStateToJson(
        NotificationInitState instance) =>
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
