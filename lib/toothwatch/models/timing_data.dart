import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timing_data.g.dart';

@JsonSerializable()
class TimingData extends Equatable {
  final List<double> times;
  final double sumTimes;

  TimingData({List<double> times, double sumTimes}) : times = (times == null ? [] : times), sumTimes = (sumTimes == null ? 0 : sumTimes);
  TimingData.empty() : this(times: [], sumTimes: 0);
  TimingData withNewTime(double time) {
    var newTimes = times.toList(); // Copy the time list
    newTimes.add(time);
    var newSumTimes = sumTimes + time;
    return TimingData(times: newTimes, sumTimes: newSumTimes);
  }

  factory TimingData.fromJson(Map<String, dynamic> json) => _$TimingDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimingDataToJson(this);

  @override
  List<Object> get props => [times, sumTimes];
}