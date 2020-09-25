// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stopwatch_persistent_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopwatchPersistentState _$StopwatchPersistentStateFromJson(
    Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['timingData']);
  return StopwatchPersistentState(
    timingData: json['timingData'] == null
        ? null
        : TimingData.fromJson(json['timingData'] as Map<String, dynamic>),
    timerStartEpochMs: json['timerStartEpochMs'] as int,
  );
}

Map<String, dynamic> _$StopwatchPersistentStateToJson(
    StopwatchPersistentState instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('timingData', instance.timingData);
  val['timerStartEpochMs'] = instance.timerStartEpochMs;
  return val;
}
