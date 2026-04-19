import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/core/user_settings_sync.dart';
import 'package:waseel/features/passenger/providers/wallet_provider.dart';

/// Syncs driver dashboard or passenger wallet, then full user settings (`GET /users/settings`).
/// [SessionGate] handles cold start; sign-in flows use named routes and bypass it.
Future<void> syncShellDataAfterLogin(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  final driver = context.read<DriverProvider>();
  final wallet = context.read<WalletProvider>();
  final t = auth.token;
  if (t == null || t.isEmpty || t == 'local-session') return;
  if (auth.user?.role == 'Driver') {
    await driver.syncFromBackend(t, auth.user?.role);
  } else {
    await wallet.syncBalanceFromBackend(t);
  }
  if (!context.mounted) return;
  await syncUserSettingsFromApi(context);
}
