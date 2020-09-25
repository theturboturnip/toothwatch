import 'dart:convert';

import 'package:toothwatch/toothwatch/util/duration_utils.dart';

import 'notification_text.dart';
import 'persistent_notification_state.dart';

// double _computeNotificationTimerSeconds(String notificationInitStateJson) {
//   final initState = PersistentNotificationState.fromJsonStr(notificationInitStateJson);
//
//   return initState.secondsSinceInit();
// }

NotificationText _computeNewNotificationText(PersistentNotificationState initState) {
  final timeRemaining = durationFromPartialSeconds(seconds: initState.totalSecondsRemaining());
  final timeSinceInit = durationFromPartialSeconds(seconds: initState.secondsSinceInit());

  return NotificationText(
      title: remainingDurationToStringPretty(timeRemaining),
      subtitle: "Current session: ${durationToStringPretty(timeSinceInit)}"
  );
}

NotificationText _computeAlertNotificationText(double secondsSinceInitModBoundary) {
  final secondsSinceInitDuration = durationFromPartialSeconds(seconds: secondsSinceInitModBoundary);
  return NotificationText(
    title: "${durationToStringPretty(secondsSinceInitDuration)} reached",
    subtitle: "Have you forgotten to stop the timer?"
  );
}

PersistentNotificationEvalData evalPersistentNotification(final PersistentNotificationState state) {
  // Whenever we cross a *boundary* of 10 minutes in *time elapsed for this session* send an alert
  // So we need to store the "previously evaluated time"
  final ALERT_BOUNDARY_SECONDS = 10.0 * 60.0;
  final secondsSinceInit = state.secondsSinceInit();
  final alarmsSinceInit = (secondsSinceInit / ALERT_BOUNDARY_SECONDS).floor();
  final previousAlarmsSinceInit = (state.previousSecondsSinceInit / ALERT_BOUNDARY_SECONDS).floor();
  NotificationText alertNotificationText = null;
  if (secondsSinceInit > ALERT_BOUNDARY_SECONDS && alarmsSinceInit > previousAlarmsSinceInit)
    alertNotificationText = _computeAlertNotificationText(alarmsSinceInit * ALERT_BOUNDARY_SECONDS);

  // Evaluate every 10 seconds by default, because the text usually shows minutes
  int nextNotificationDelayMillis = 10 * 1000;
  // But if we are showing text in seconds, update every 500 milliseconds
  if (secondsSinceInit < 60)
    nextNotificationDelayMillis = 500;

  final newState = state.withNewPreviousState(secondsSinceInit);

  return PersistentNotificationEvalData.fromState(
    newState,
    persistentNotificationText: _computeNewNotificationText(state),
    alertNotificationText: alertNotificationText,
    nextNotificationDelayMillis: nextNotificationDelayMillis
  );
}