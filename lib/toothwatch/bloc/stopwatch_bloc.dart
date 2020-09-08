import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:optional/optional.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        super(StopwatchInitial(timingData)) {
    add(StopwatchLoad());
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<StopwatchState> mapEventToState(
    StopwatchEvent event,
  ) async* {
    final newState = await _transitionByEvent(event);
    if (state.timingData != newState.timingData)
      await saveTimingData(newState);
    yield newState;
  }

  Future<StopwatchState> loadNewStateFromSurroundings() async {
    TimingData loadedTimingData = await loadTimingData();
    Optional<NotificationInitState> stopwatchNotificationInitState = await _javaTimerControl.getTimerStateAndClose();

    if (stopwatchNotificationInitState.isPresent) {
      // NOTE - returning a new state with the correct suspend value is correct.
      //  returning StopwatchIdle and enqueueing a StopwatchStart would *not* be.
      //  this is because we don't know what's queued after us - if we unsuspend and have a suspend directly afterwards, we'd suspend incorrect state.
      _startTicker();

      return StopwatchTicking(loadedTimingData,
          secondsElapsed: stopwatchNotificationInitState.value.secondsSinceInit());
    }
    return StopwatchIdle(loadedTimingData);
  }

  static final String TIMING_DATA_PREF = "TimingData";

  void saveTimingData(StopwatchState toSave) async {
    print("Saving timing data ${toSave.timingData}");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(TIMING_DATA_PREF, jsonEncode(toSave.timingData.toJson()));
  }

  Future<TimingData> loadTimingData() async {
    print("Loading timing data");
    final prefs = await SharedPreferences.getInstance();
    final timingDataStr = prefs.getString(TIMING_DATA_PREF);
    if (timingDataStr == null) {
      print("Got null timing data");
      return TimingData.empty();
    }
    print("Got string $timingDataStr");
    return TimingData.fromJson(jsonDecode(timingDataStr));
  }

  Future<StopwatchState> _transitionByEvent(StopwatchEvent event) async {
    if (state is StopwatchInitial) {
      if (event is StopwatchLoad) {
        return loadNewStateFromSurroundings();
      }
    } else if (state is StopwatchSuspended) {
      // Only accept Unsuspend or Serialize events
      if (event is StopwatchUnsuspend) {
        print("Unsuspending!");

        return loadNewStateFromSurroundings();
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
