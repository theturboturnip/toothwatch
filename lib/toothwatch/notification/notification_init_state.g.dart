// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_init_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationInitState _$NotificationInitStateFromJson(
    Map<String, dynamic> json) {
  return NotificationInitState(
    secondsElapsedAtStart: (json['secondsElapsedAtStart'] as num)?.toDouble(),
    millisecondsEpochAtStart: json['millisecondsEpochAtStart'] as int,
  );
}

Map<String, dynamic> _$NotificationInitStateToJson(
        NotificationInitState instance) =>
    <String, dynamic>{
      'secondsElapsedAtStart': instance.secondsElapsedAtStart,
      'millisecondsEpochAtStart': instance.millisecondsEpochAtStart,
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
