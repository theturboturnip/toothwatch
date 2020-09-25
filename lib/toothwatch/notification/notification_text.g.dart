// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
