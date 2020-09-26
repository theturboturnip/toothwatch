import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toothwatch/toothwatch/models/stopwatch_persistent_state.dart';
import 'package:toothwatch/toothwatch/bloc/ticker.dart';
import 'package:toothwatch/toothwatch/interop/foregound_channel.dart';
import 'package:toothwatch/toothwatch/models/timing_data.dart';
import 'package:toothwatch/toothwatch/notification/persistent_notification_state.dart';
import 'package:toothwatch/toothwatch/util/duration_utils.dart';

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
    if (state.getPersistentData() != newState.getPersistentData())
      savePersistentData(newState);
    yield newState;
  }

  Future<StopwatchState> loadNewStateFromSurroundings() async {
    final loadedPersistentData = await loadPersistentData();
    final hadService = await _closeServiceIfPresent();

    if (loadedPersistentData.timerStartEpochMs != null) {
      final MAX_SECONDS_WITHOUT_SERVICE = 15.0 * 60.0;
      // If we don't have a service, we assume that something weird has happened - the phone may have died, or the user may have force quit the app. In that case, the user may have put their teeth back in if it took a long time, so give them the benefit of the doubt.
      if (!hadService && secondsSince(loadedPersistentData.timerStartEpochMs) > MAX_SECONDS_WITHOUT_SERVICE) {
        print("No service found, and the time we would add exceeds the maximum. Only adding the maximum.");
        return StopwatchIdle(
            loadedPersistentData.timingData.withNewTime(MAX_SECONDS_WITHOUT_SERVICE));
      } else {
        // If there was a timer started within 10 minutes of start, continue it.

        // NOTE - returning a new state with the correct suspend value is correct.
        //  returning StopwatchIdle and enqueueing a StopwatchStart would *not* be.
        //  this is because we don't know what's queued after us - if we unsuspend and have a suspend directly afterwards, we'd suspend incorrect state.
        _startTicker();
        final newState = StopwatchTicking.fromPersistent(loadedPersistentData,
            secondsElapsed: secondsSince(loadedPersistentData.timerStartEpochMs));
        _startService(newState);
        return newState;
      }
    }
    return StopwatchIdle(loadedPersistentData.timingData);
  }

  static final String PERSISTENT_DATA_PREF = "PersistentData";

  void savePersistentData(StopwatchState toSave) async {
    final persistentData = toSave.getPersistentData();
    print("Saving timing data ${persistentData}");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(PERSISTENT_DATA_PREF, jsonEncode(persistentData.toJson()));
  }

  Future<StopwatchPersistentState> loadPersistentData() async {
    print("Loading persistent data");
    final prefs = await SharedPreferences.getInstance();
    final persistentDataStr = prefs.getString(PERSISTENT_DATA_PREF);
    if (persistentDataStr != null) {
      print("Loaded persistent data string $persistentDataStr");
      try {
        return StopwatchPersistentState.fromJson(jsonDecode(persistentDataStr));
      } on FormatException catch(e) {
        print("Invalid JSON exception ${e} on depersist, returning cleared data");
        return StopwatchPersistentState.cleared();
      } on BadKeyException catch(e) {
        print("Invalid JSON exception ${e} on depersist, returning cleared data");
        return StopwatchPersistentState.cleared();
      }
    }
    print("Got null timing data");
    return StopwatchPersistentState.cleared();
  }

  Future<StopwatchState> _transitionByEvent(StopwatchEvent event) async {
    if (state is StopwatchInitial) {
      if (event is StopwatchLoad) {
        return loadNewStateFromSurroundings();
      }
    } else {
      if (event is StopwatchToggled) {
        // Cancel the timer - this could be done
        if (state is StopwatchTicking) {
          // Stopped timing
          _stopTicker();
          _closeServiceIfPresent();
          return StopwatchIdle(
              state.timingData.withNewTime(
                  (state as StopwatchTicking).secondsElapsed));
        } else {
          // Start the timer
          _startTicker();
          final newState = StopwatchTicking(state.timingData, timerStartEpochMs: _getMillisecondsSinceEpoch(), secondsElapsed: 0);
          _startService(newState);
          return newState;
        }
      } else if (event is StopwatchTicked) {
        if (state is StopwatchTicking)
          return StopwatchTicking.fromPersistent(
              state.getPersistentData(),
              secondsElapsed: (state as StopwatchTicking).secondsElapsed + 0.1);
      } else if (event is StopwatchCleared) {
        return StopwatchIdle(TimingData.empty());
      }
    }

    print("Got unhandled event $event while in state $state");
    return state;
  }

  void _startService(StopwatchTicking state) async {
    await _javaTimerControl.startTimerService(
        initialState: PersistentNotificationState.fromStopwatchState(state.getPersistentData())
    );
  }
  Future<bool> _closeServiceIfPresent() async => _javaTimerControl.closeTimerServiceIfPresent();

  int _getMillisecondsSinceEpoch() => DateTime.now().millisecondsSinceEpoch;

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
