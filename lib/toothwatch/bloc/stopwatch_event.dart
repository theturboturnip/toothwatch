part of 'stopwatch_bloc.dart';

abstract class StopwatchEvent extends Equatable {
  const StopwatchEvent();

  @override
  List<Object> get props => [];
}

class StopwatchLoad extends StopwatchEvent {}

class StopwatchToggled extends StopwatchEvent {}

class StopwatchCleared extends StopwatchEvent {}

class StopwatchTicked extends StopwatchEvent {}

// class StopwatchSuspend extends StopwatchEvent {}
//
// class StopwatchUnsuspend extends StopwatchEvent {}