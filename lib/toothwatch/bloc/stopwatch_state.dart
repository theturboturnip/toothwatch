part of 'stopwatch_bloc.dart';

abstract class StopwatchState extends Equatable {
  final TimingData timingData;

  const StopwatchState(this.timingData);

  @override
  List<Object> get props => [timingData];
}

class StopwatchIdle extends StopwatchState {
  const StopwatchIdle(TimingData timingData) : super(timingData);
}

class StopwatchTicking extends StopwatchState {
  final double secondsElapsed;

  const StopwatchTicking(TimingData timingData, this.secondsElapsed) : super(timingData);

  @override
  List<Object> get props => [timingData, secondsElapsed];
}