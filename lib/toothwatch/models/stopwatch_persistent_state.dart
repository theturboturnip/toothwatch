import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:toothwatch/toothwatch/models/timing_data.dart';

part 'stopwatch_persistent_state.g.dart';

@JsonSerializable()
class StopwatchPersistentState extends Equatable {
  @JsonKey(disallowNullValue: true)
  final TimingData timingData;
  @JsonKey(includeIfNull: true)
  final int timerStartEpochMs;

  StopwatchPersistentState({TimingData timingData, int timerStartEpochMs}) :
      this.timingData = (timingData == null) ? TimingData.empty() : timingData,
      this.timerStartEpochMs = timerStartEpochMs;
  StopwatchPersistentState.cleared() : this();

  StopwatchPersistentState withNewTime(double time) {
    return StopwatchPersistentState(timingData: timingData.withNewTime(time), timerStartEpochMs: timerStartEpochMs);
  }

  factory StopwatchPersistentState.fromJson(Map<String, dynamic> json) => _$StopwatchPersistentStateFromJson(json);
  Map<String, dynamic> toJson() => _$StopwatchPersistentStateToJson(this);

  @override
  List<Object> get props => [timingData, timerStartEpochMs];
}