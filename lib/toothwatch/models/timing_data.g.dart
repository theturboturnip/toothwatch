// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timing_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimingData _$TimingDataFromJson(Map<String, dynamic> json) {
  return TimingData(
    times:
        (json['times'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
    expectedTotalTimeSeconds:
        (json['expectedTotalTimeSeconds'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$TimingDataToJson(TimingData instance) =>
    <String, dynamic>{
      'times': instance.times,
      'expectedTotalTimeSeconds': instance.expectedTotalTimeSeconds,
    };
