import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:toothwatch/toothwatch/bloc/ticker.dart';
import 'package:toothwatch/toothwatch/models/timing_data.dart';

part 'stopwatch_event.dart';
part 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  final Ticker _ticker;
  StreamSubscription<int> _tickerSubscription;

  StopwatchBloc({@required Ticker ticker, @required TimingData timingData})
      : assert(ticker != null),
        _ticker = ticker,
        assert(timingData != null),
        super(StopwatchIdle(timingData));

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<StopwatchState> mapEventToState(
    StopwatchEvent event,
  ) async* {
    if (event is StopwatchToggled) {
      // Cancel the timer - this could be done
      _tickerSubscription?.cancel();
      if (state is StopwatchTicking) {
        // Stopped timing
        yield StopwatchIdle(
            state.timingData.withNewTime(
                (state as StopwatchTicking).secondsElapsed));
      } else {
        // Start the timer
        _tickerSubscription = _ticker
            .sequentialTenthSeconds()
            .listen((duration) => add(StopwatchTicked()));
        yield StopwatchTicking(state.timingData, 0);
      }
    } else if (event is StopwatchTicked) {
      if (state is StopwatchTicking)
        yield StopwatchTicking(
            state.timingData, (state as StopwatchTicking).secondsElapsed + 0.1);
    } else if (event is StopwatchCleared) {
      yield StopwatchIdle(TimingData.empty());
    } else {
      print("Got unexpected event $event");
    }
  }
}
