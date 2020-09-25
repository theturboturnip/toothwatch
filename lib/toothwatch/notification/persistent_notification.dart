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

PersistentNotificationEvalData evalPersistentNotification(PersistentNotificationState state) {
  return PersistentNotificationEvalData.fromState(state, persistentNotificationText: _computeNewNotificationText(state), alertNotificationText: null);
}