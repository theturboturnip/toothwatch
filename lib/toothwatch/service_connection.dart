import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:optional/optional.dart';

class ServiceConnection {
  static const MethodChannel platform = MethodChannel("com.example.toothwatch/timer");

  Future<void> startTimerService({@required double secondsElapsed}) async {
    try {
      await platform.invokeMethod<void>('startTimerService', <String, dynamic>{
        "secondsElapsed": secondsElapsed
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<Optional<double>> retrieveTimerSecondsAndClose() async {
    try {
      double unpackedValue = await platform.invokeMethod<double>('retrieveTimerSecondsAndClose');
      if (unpackedValue < 0) {
        return Optional.empty();
      } else {
        return Optional.of(unpackedValue);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}