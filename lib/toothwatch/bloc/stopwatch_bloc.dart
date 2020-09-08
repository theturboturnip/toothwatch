import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:optional/optional.dart';
import 'package:toothwatch/toothwatch/bloc/ticker.dart';
import 'package:toothwatch/toothwatch/interop/foregound_channel.dart';
import 'package:toothwatch/toothwatch/models/timing_data.dart';
import 'package:toothwatch/toothwatch/notification/notification_init_state.dart';

part 'stopwatch_event.dart';
part 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  final Ticker _ticker;
  StreamSubscription<int> _tickerSubscription;
  ForegroundChannel _javaTimerControl;

  StopwatchBloc({@required Ticker ticker, @required TimingData timingData})
      : assert(ticker != null),
        _ticker = ticker,
        _javaTimerControl = ForegroundChannel(),
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
    yield await _transitionByEvent(event);
  }

  Future<StopwatchState> _transitionByEvent(StopwatchEvent event) async {
    if (state is StopwatchSuspended) {
      // Only accept Unsuspend or Serialize events
      if (event is StopwatchUnsuspend) {
        print("Unsuspending!");

        TimingData loadedTimingData = state.timingData;//TimingData.empty();
        Optional<NotificationInitState> stopwatchNotificationInitState = await _javaTimerControl.getTimerStateAndClose();
        // TODO - load timer data from background
        if (stopwatchNotificationInitState.isPresent) {
          // NOTE - returning a new state with the correct suspend value is correct.
          //  returning StopwatchIdle and enqueueing a StopwatchStart would *not* be.
          //  this is because we don't know what's queued after us - if we unsuspend and have a suspend directly afterwards, we'd suspend incorrect state.
          _startTicker();

          return StopwatchTicking(loadedTimingData,
              secondsElapsed: stopwatchNotificationInitState.value.secondsSinceInit());
        }
        return StopwatchIdle(loadedTimingData);
      } else if (event is StopwatchSerialize) {
        // TODO - call serialize function
      }
    } else {
      if (event is StopwatchToggled) {
        // Cancel the timer - this could be done
        if (state is StopwatchTicking) {
          // Stopped timing
          _stopTicker();
          return StopwatchIdle(
              state.timingData.withNewTime(
                  (state as StopwatchTicking).secondsElapsed));
        } else {
          // Start the timer
          _startTicker();
          return StopwatchTicking(state.timingData, secondsElapsed: 0);
        }
      } else if (event is StopwatchTicked) {
        if (state is StopwatchTicking)
          return StopwatchTicking(
              state.timingData,
              secondsElapsed: (state as StopwatchTicking).secondsElapsed + 0.1);
      } else if (event is StopwatchCleared) {
        return StopwatchIdle(TimingData.empty());
      } else if (event is StopwatchSuspend) {
        print("Suspending!");

        // Kick off the background timer if necessary
        _stopTicker();
        if (state is StopwatchTicking)
          await _javaTimerControl.startTimerService(
              initialState: NotificationInitState(
                secondsElapsedAtStart: (state as StopwatchTicking).secondsElapsed,
                millisecondsEpochAtStart: DateTime.now().millisecondsSinceEpoch
              )
          );

        return StopwatchSuspended(state.timingData);
      } else if (event is StopwatchSerialize) {
        // TODO - call serialize function
      } else if (event is StopwatchDeserialize) {
        // TODO - call deserialize function
      }
    }

    print("Got unhandled event $event while in state $state");
    return state;
  }

  void _startTicker() {
    _stopTicker();
    _tickerSubscription = _ticker
        .sequentialTenthSeconds()
        .listen((duration) => add(StopwatchTicked()));
  }
  void _stopTicker() {
    _tickerSubscription?.cancel();
  }
}
