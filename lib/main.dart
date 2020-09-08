import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/stopwatch_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/ticker.dart';
import 'package:toothwatch/toothwatch/models/timing_data.dart';
import 'package:toothwatch/toothwatch/widgets/stopwatch.dart';

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
        child: StopwatchPage(),
      ),
    );
  }
}


