import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/stopwatch_bloc.dart';
import 'package:toothwatch/toothwatch/widgets/stopwatch_actions.dart';
import 'package:toothwatch/toothwatch/widgets/stopwatch_lifecycle_watchdog.dart';

class StopwatchPage extends StatelessWidget {
  static const TextStyle timeRemainingText = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static String _printDurationFull(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String secondFractionDigit = (duration.inMilliseconds.remainder(1000) ~/ 100).toString();
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds.$secondFractionDigit";
  }

  static String _printUnitPretty(int value, String unit) {
    if (value == 1)
      return "${value} ${unit}";
    else
      return "${value} ${unit}s";
  }

  static String _printDurationPretty(Duration duration) {
    assert(!duration.isNegative);

    final String hours = _printUnitPretty(duration.inHours, "hour");
    final String minutes = _printUnitPretty(duration.inMinutes % 60, "minute");
    final String seconds = _printUnitPretty(duration.inSeconds % 60, "second");

    if (duration.inHours > 0) {
      if (duration.inMinutes > 0) {
        return "${hours} and ${minutes}";
      } else {
        return hours;
      }
    } else {
      if (duration.inMinutes > 0) {
        return minutes;
      } else {
        return seconds;
      }
    }
  }

  static Duration _durationOfSeconds({@required double seconds}) {
    return Duration(milliseconds: (seconds * 1000.0).truncate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Toothwatch")),
      body: StopwatchLifecycleWatchdog(
        bloc: BlocProvider.of<StopwatchBloc>(context),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 100.0, horizontal: 20.0),
          child: Stack(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: BlocBuilder<StopwatchBloc, StopwatchState>(
                  builder: (context, state) {
                    List<double> timesToDisplay = [];
                    if (state is StopwatchTicking)
                      timesToDisplay.add(state.secondsElapsed);
                    timesToDisplay.addAll(state.timingData.times.reversed);

                    var previousTimes = ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 200
                        ),
                        child: ListView(
                          padding: const EdgeInsets.all(8),
                          children: timesToDisplay.map(
                                  (time) {
                                final String timeStr = _printDurationFull(_durationOfSeconds(seconds: time));
                                return Container(
                                  height: 20,
                                  color: Colors.transparent,
                                  child: Center(child: Text(timeStr)),
                                );
                              }
                          ).toList(),
                        )
                    );

                    double elapsedTime = timesToDisplay.fold(0.0, (curr, next) => curr + next);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(_printDurationPretty(_durationOfSeconds(seconds: elapsedTime)), style: timeRemainingText),
                        ),
                        previousTimes,
                      ],
                    );
                  },
                ),
              ),
              BlocBuilder<StopwatchBloc, StopwatchState>(
                buildWhen: (previousState, state) => state.runtimeType != previousState.runtimeType,
                builder: (context, state) => StopwatchActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}