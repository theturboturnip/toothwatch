import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:optional/optional.dart';

class ServiceConnection {
  static const MethodChannel platform = MethodChannel("com.example.toothwatch/timer");

  Future<void> startTimerService({@required double secondsElapsed}) async {
    await platform.invokeMethod<void>('startTimerService', <String, dynamic>{
      "secondsElapsed": secondsElapsed
    });
  }

  Future<Optional<double>> retrieveTimerSecondsAndClose() async {
    double unpackedValue = await platform.invokeMethod<double>('retrieveTimerSecondsAndClose');
    if (unpackedValue < 0) {
      return Optional.empty();
    } else {
      return Optional.of(unpackedValue);
    }
  }
}