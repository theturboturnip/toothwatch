class TimingData {
  final List<double> times;
  final double sumTimes;

  TimingData.empty() : times = [], sumTimes = 0;
  TimingData.fromData(this.times, this.sumTimes);
  TimingData withNewTime(double time) {
    var newTimes = times.toList(); // Copy the time list
    newTimes.add(time);
    var newSumTimes = sumTimes + time;
    return TimingData.fromData(newTimes, newSumTimes);
  }
}