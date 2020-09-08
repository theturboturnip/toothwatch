import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/stopwatch_bloc.dart';
import 'package:toothwatch/toothwatch/util/duration_utils.dart';
import 'package:toothwatch/toothwatch/widgets/stopwatch_actions.dart';
import 'package:toothwatch/toothwatch/widgets/stopwatch_lifecycle_watchdog.dart';

class StopwatchPage extends StatelessWidget {
  static const TextStyle timeRemainingText = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

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
                                final String timeStr = durationToStringFull(durationFromPartialSeconds(seconds: time));
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
                    double remainingTime = state.timingData.expectedTotalTimeSeconds - elapsedTime;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(remainingDurationToStringPretty(durationFromPartialSeconds(seconds: remainingTime)), style: timeRemainingText),
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