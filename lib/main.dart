import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/stopwatch_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/ticker.dart';
import 'package:toothwatch/toothwatch/models/timing_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: 'Toothwatch',
      home: BlocProvider(
        create: (context) => StopwatchBloc(ticker: Ticker(), timingData: TimingData.empty()),
        child: Stopwatch(),
      ),
    );
  }
}

// <Widget>[
// Container(
// height: 50,
// color: Colors.amber[600],
// child: const Center(child: Text('Entry A')),
// ),
// Container(
// height: 50,
// color: Colors.amber[500],
// child: const Center(child: Text('Entry B')),
// ),
// Container(
// height: 50,
// color: Colors.amber[100],
// child: const Center(child: Text('Entry C')),
// ),
// ],

class Stopwatch extends StatelessWidget {
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
    final String minutes = _printUnitPretty(duration.inMinutes, "minute");
    final String seconds = _printUnitPretty(duration.inSeconds, "second");

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
      body: AppSuspendWatchdog(
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
                builder: (context, state) => Actions(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _mapStateToActionButtons(
        BlocProvider.of<StopwatchBloc>(context),
      ),
    );
  }

  List<Widget> _mapStateToActionButtons(StopwatchBloc bloc) {
    final StopwatchState state = bloc.state;

    if (state is StopwatchIdle) {
      return [
        Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            child: Icon(Icons.timer),
            tooltip: "Remove teeth",
            onPressed: () => bloc.add(StopwatchToggled()),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            child: Icon(Icons.clear),
            onPressed: () => bloc.add(StopwatchCleared()),
          ),
        ),
      ];
    } else if (state is StopwatchTicking) {
      return [
        Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
            child: Icon(Icons.timer_off),
            tooltip: "Put teeth back",
            onPressed: () => bloc.add(StopwatchToggled()),
          ),
        ),
      ];
    }
  }
}


class AppSuspendWatchdog extends StatefulWidget {
  const AppSuspendWatchdog({
    Key key,
    @required this.bloc,
    this.child,
  }) : super(key: key);

  final StopwatchBloc bloc;
  final Widget child;

  @override
  State<AppSuspendWatchdog> createState() => _AppSuspendWatchdogState();
}

class _AppSuspendWatchdogState extends State<AppSuspendWatchdog> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch(state) {
      case AppLifecycleState.resumed:
        widget.bloc.add(StopwatchUnsuspend());
        break;
      case AppLifecycleState.paused:
        widget.bloc.add(StopwatchSuspend());
        break;

      case AppLifecycleState.inactive:
      // TODO: Handle this case.
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}