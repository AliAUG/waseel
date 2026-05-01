import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/health_api_service.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/driver/screens/driver_shell.dart';
import 'package:waseel/features/onboarding/screens/onboarding_screen.dart';
import 'package:waseel/core/user_settings_sync.dart';
import 'package:waseel/features/passenger/providers/wallet_provider.dart';
import 'package:waseel/features/passenger/screens/passenger_shell.dart';

/// Loads saved auth on startup, syncs profile when token is real, then shows
/// [OnboardingScreen] or main shell.
class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final driver = context.read<DriverProvider>();
      final wallet = context.read<WalletProvider>();
      await Future.wait<void>([
        auth.loadPersistedSession(),
        _startupHealthPing(),
      ]);
      // Real JWT: refresh user from server so name/role/stats stay current.
      final t = auth.token;
      if (auth.isLoggedIn &&
          t != null &&
          t.isNotEmpty &&
          t != 'local-session') {
        await auth.refreshProfile();
      }
      if (auth.isLoggedIn &&
          t != null &&
          t.isNotEmpty &&
          t != 'local-session') {
        if (auth.user?.role == 'Driver') {
          await driver.syncFromBackend(
            t,
            auth.user?.role,
          );
        } else {
          await wallet.syncBalanceFromBackend(t);
        }
        if (!mounted) return;
        await syncUserSettingsFromApi(context);
      }
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final auth = context.watch<AuthProvider>();
    if (auth.isLoggedIn) {
      final isDriver = auth.user?.role == 'Driver';
      return isDriver ? const DriverShell() : const PassengerShell();
    }
    return const OnboardingScreen();
  }
}

/// Runs once at cold start alongside [AuthProvider.loadPersistedSession].
/// Does not block UX beyond the shared splash; failures are debug-only.
Future<void> _startupHealthPing() async {
  try {
    await HealthApiService()
        .fetchHealth()
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    if (kDebugMode) {
      debugPrint('Waseel: startup GET /health failed or timed out');
    }
  }
}
