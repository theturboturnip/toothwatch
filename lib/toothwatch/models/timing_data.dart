import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timing_data.g.dart';

@JsonSerializable()
class TimingData extends Equatable {
  final List<double> times;
  @JsonKey(ignore: true)
  final double sumTimes;
  final double expectedTotalTimeSeconds;

  static const double DEFAULT_EXPECTED_TOTAL_TIME = 2.0 * 60.0 * 60.0;

  TimingData({List<double> times, double expectedTotalTimeSeconds})
      : times = (times == null ? [] : times),
        sumTimes = (times == null ? 0 : times.fold(0.0, (curr, next) => curr + next)),
        expectedTotalTimeSeconds = (expectedTotalTimeSeconds == null ? DEFAULT_EXPECTED_TOTAL_TIME : expectedTotalTimeSeconds);
  TimingData.empty() : this();
  TimingData withNewTime(double time) {
    var newTimes = times.toList(); // Copy the time list
    newTimes.add(time);
    return TimingData(times: newTimes);
  }

  factory TimingData.fromJson(Map<String, dynamic> json) => _$TimingDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimingDataToJson(this);

  @override
  List<Object> get props => [times, expectedTotalTimeSeconds];
}