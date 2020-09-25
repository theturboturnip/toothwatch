part of 'stopwatch_bloc.dart';

abstract class StopwatchState extends Equatable {
  final TimingData timingData;

  const StopwatchState(this.timingData);

  StopwatchPersistentState getPersistentData() => StopwatchPersistentState(timingData: timingData);

  @override
  List<Object> get props => [timingData];
}

class StopwatchInitial extends StopwatchState {
  const StopwatchInitial(TimingData timingData) : super(timingData);
}

class StopwatchIdle extends StopwatchState {
  const StopwatchIdle(TimingData timingData) : super(timingData);
}

// class StopwatchSuspended extends StopwatchState {
//   final int timerStartEpochMs;
//
//   StopwatchSuspended(StopwatchPersistentState persistentState) : this.timerStartEpochMs = persistentState.timerStartEpochMs, super(persistentState.timingData);
//
//   @override
//   StopwatchPersistentState getPersistentData() => StopwatchPersistentState(timingData: timingData, timerStartEpochMs: timerStartEpochMs);
// }

class StopwatchTicking extends StopwatchState {
  final double secondsElapsed;
  final int timerStartEpochMs;

  const StopwatchTicking(TimingData timingData, {@required this.timerStartEpochMs, @required this.secondsElapsed}) : super(timingData);
  StopwatchTicking.fromPersistent(StopwatchPersistentState persistentState, {@required double secondsElapsed}) : this(persistentState.timingData, timerStartEpochMs: persistentState.timerStartEpochMs, secondsElapsed: secondsElapsed);

  @override
  StopwatchPersistentState getPersistentData() => StopwatchPersistentState(timingData: timingData, timerStartEpochMs: timerStartEpochMs);

  @override
  List<Object> get props => [timingData, secondsElapsed];
}