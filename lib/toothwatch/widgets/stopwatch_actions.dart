import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/stopwatch_bloc.dart';

class StopwatchActions extends StatelessWidget {
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

    if (state is StopwatchTicking) {
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
    } else {
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
    }
  }
}