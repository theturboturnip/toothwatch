import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/stopwatch_bloc.dart';
import 'package:toothwatch/toothwatch/bloc/ticker.dart';
import 'package:toothwatch/toothwatch/interop/background_channel.dart';
import 'package:toothwatch/toothwatch/models/timing_data.dart';
import 'package:toothwatch/toothwatch/widgets/stopwatch.dart';

void initializeAndroidWidgets() {
  if (Platform.isAndroid) {
    // Intialize flutter
    WidgetsFlutterBinding.ensureInitialized();

    const MethodChannel channel = MethodChannel('com.example.toothwatch/timer');

    final CallbackHandle callback = PluginUtilities.getCallbackHandle(backgroundChannel);
    final handle = callback.toRawHandle();

    channel.invokeMethod('setBackgroundChannelHandle', handle);
  }
}

void main() {
  initializeAndroidWidgets();
  runApp(MyApp());
}

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


