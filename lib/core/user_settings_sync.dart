import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/user_api_service.dart';
import 'package:waseel/features/passenger/providers/notification_settings_provider.dart';
import 'package:waseel/features/passenger/providers/privacy_safety_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

/// One `GET /users/settings` call; applies language/theme, notification toggles,
/// and privacy flags to match [UserSettings] on the server.
Future<void> syncUserSettingsFromApi(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  final t = auth.token;
  if (t == null || t.isEmpty || t == 'local-session') return;

  Map<String, dynamic>? map;
  try {
    map = await UserApiService().getSettings(t);
  } on ApiException {
    return;
  } catch (_) {
    return;
  }

  if (map == null || !context.mounted) return;

  context.read<SettingsProvider>().applyFromBackend(map);

  final n = map['notifications'];
  if (n is Map) {
    context.read<NotificationSettingsProvider>().applyFromServerMap(
          Map<String, dynamic>.from(n),
        );
  }

  final p = map['privacy'];
  if (p is Map) {
    context.read<PrivacySafetyProvider>().applyFromServerMap(
          Map<String, dynamic>.from(p),
        );
  }

  final ec = map['emergencyContacts'];
  if (ec is List) {
    context.read<PrivacySafetyProvider>().applyEmergencyContactsFromServer(ec);
  }
}

/// Persists notification toggles via `PUT /users/settings` (`notifications` key).
Future<void> pushNotificationSettingsToServer(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  final t = auth.token;
  if (t == null || t.isEmpty || t == 'local-session') return;
  final notif = context.read<NotificationSettingsProvider>();
  try {
    await UserApiService().updateSettings(t, {
      'notifications': notif.toServerNotificationsMap(),
    });
  } on ApiException {
    /* keep local prefs */
  } catch (_) {}
}

/// Persists privacy toggles via `PUT /users/settings` (`privacy` key).
Future<void> pushPrivacySettingsToServer(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  final t = auth.token;
  if (t == null || t.isEmpty || t == 'local-session') return;
  final privacy = context.read<PrivacySafetyProvider>();
  try {
    await UserApiService().updateSettings(t, {
      'privacy': privacy.toServerPrivacyMap(),
    });
  } on ApiException {
    /* keep local state */
  } catch (_) {}
}

/// Persists `emergencyContacts` via `PUT /users/settings`.
Future<void> pushEmergencyContactsToServer(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  final t = auth.token;
  if (t == null || t.isEmpty || t == 'local-session') return;
  final privacy = context.read<PrivacySafetyProvider>();
  try {
    await UserApiService().updateSettings(t, {
      'emergencyContacts': privacy.emergencyContactsToServerList(),
    });
  } on ApiException {
    /* keep local state */
  } catch (_) {}
}

/// After local [setter] runs, syncs the full notification document to the server.
ValueChanged<bool> notificationToggleWithSync(
  BuildContext context,
  void Function(bool) setter,
) {
  return (v) {
    setter(v);
    unawaited(pushNotificationSettingsToServer(context));
  };
}

/// After local [setter] runs, syncs the full privacy document to the server.
ValueChanged<bool> privacyToggleWithSync(
  BuildContext context,
  void Function(bool) setter,
) {
  return (v) {
    setter(v);
    unawaited(pushPrivacySettingsToServer(context));
  };
}
