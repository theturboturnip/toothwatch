import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:toothwatch/toothwatch/bloc/stopwatch_bloc.dart';

class StopwatchLifecycleWatchdog extends StatefulWidget {
  const StopwatchLifecycleWatchdog({
    Key key,
    @required this.bloc,
    this.child,
  }) : super(key: key);

  final StopwatchBloc bloc;
  final Widget child;

  @override
  State<StopwatchLifecycleWatchdog> createState() => _AppSuspendWatchdogState();
}

class _AppSuspendWatchdogState extends State<StopwatchLifecycleWatchdog> with WidgetsBindingObserver {
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

    // switch(state) {
    //   case AppLifecycleState.resumed:
    //     widget.bloc.add(StopwatchUnsuspend());
    //     break;
    //   case AppLifecycleState.paused:
    //     widget.bloc.add(StopwatchSuspend());
    //     break;
    //
    //   case AppLifecycleState.inactive:
    //   // TODO: Handle this case.
    //     break;
    //   case AppLifecycleState.detached:
    //   // TODO: Handle this case.
    //     break;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}