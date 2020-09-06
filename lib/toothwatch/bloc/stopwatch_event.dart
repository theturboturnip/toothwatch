part of 'stopwatch_bloc.dart';

abstract class StopwatchEvent extends Equatable {
  const StopwatchEvent();

  @override
  List<Object> get props => [];
}

class StopwatchToggled extends StopwatchEvent {}

class StopwatchCleared extends StopwatchEvent {}

class StopwatchTicked extends StopwatchEvent {}