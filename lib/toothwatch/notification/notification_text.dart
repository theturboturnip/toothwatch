import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_text.g.dart';

@JsonSerializable()
class NotificationText {
  final String title;
  final String subtitle;

  const NotificationText({@required this.title, this.subtitle});

  factory NotificationText.fromJson(Map<String, dynamic> json) => _$NotificationTextFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationTextToJson(this);
}