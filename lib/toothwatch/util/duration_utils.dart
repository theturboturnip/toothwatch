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

Duration durationFromPartialSeconds({@required double seconds}) {
  return Duration(milliseconds: (seconds * 1000.0).truncate());
}
