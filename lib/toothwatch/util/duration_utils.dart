import 'package:flutter/foundation.dart';

String durationToStringFull(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String secondFractionDigit =
      (duration.inMilliseconds.remainder(1000) ~/ 100).toString();
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds.$secondFractionDigit";
}

String _printUnitPretty(int value, String unit) {
  if (value == 1)
    return "${value} ${unit}";
  else
    return "${value} ${unit}s";
}

String durationToStringPretty(Duration duration) {
  assert(!duration.isNegative);

  //final hours = duration.inHours;
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;

  //final String hourStr = _printUnitPretty(hours, "hr");
  final String minuteStr = _printUnitPretty(minutes, "min");
  final String secondStr = _printUnitPretty(seconds, "second");

  //if (hours > 0) {
    if (minutes > 0) {
      return minuteStr;
    } else {
      return secondStr;
    }
  // } else {
  //   if (minutes > 0) {
  //     return minuteStr;
  //   } else {
  //     return secondStr;
  //   }
  // }
}

String remainingDurationToStringPretty(Duration duration) {
  if (duration.isNegative){
    final positiveDuration = Duration(milliseconds: -duration.inMilliseconds);
    return "OVER BY ${durationToStringPretty(positiveDuration)}";
  } else {
    return "${durationToStringPretty(duration)} remaining";
  }
}

Duration durationFromPartialSeconds({@required double seconds}) {
  return Duration(milliseconds: (seconds * 1000.0).truncate());
}

double secondsSince(int timerStartEpochMs) {
  return (DateTime.now().millisecondsSinceEpoch - timerStartEpochMs) / 1000.0;
}