import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/app_session_clear.dart';
import 'package:waseel/core/sign_out_confirm_dialog.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/auth/screens/choose_role_screen.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/driver/screens/driver_going_to_pickup_screen.dart';
import 'package:waseel/features/driver/screens/driver_notifications_screen.dart';
import 'package:waseel/features/driver/screens/driver_profile_screen.dart';
import 'package:waseel/features/driver/screens/new_ride_request_card.dart';
import 'package:waseel/features/driver/strings/driver_ui_strings.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.elementAt(1)[0]}'.toUpperCase();
}

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final d = DriverUiStrings(context.watch<SettingsProvider>().language);
    return Consumer2<DriverProvider, AuthProvider>(
      builder: (context, driverProvider, auth, _) {
        final user = auth.user;
        final driverName = user?.name ?? 'Driver';
        final vehicle = driverProvider.vehicleLabel;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: Text(
              driverProvider.isOnline ? 'ONLINE - ACCEPTING RIDES' : 'DRIVER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        driverName: driverName,
                        vehicle: vehicle,
                        d: d,
                      ),
                      const SizedBox(height: 20),
                      _StatusSection(
                        isOnline: driverProvider.isOnline,
                        onToggle: () {
                          driverProvider.toggleOnline();
                          if (driverProvider.isOnline) {
                            driverProvider.refreshIncomingRequests(
                              auth.token,
                              user?.role,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      _MetricsRow(
                        earnings: driverProvider.earningsToday,
                        trips: driverProvider.tripsToday,
                        onlineHours: driverProvider.onlineTimeHours,
                      ),
                      const SizedBox(height: 24),
                      driverProvider.isOnline
                          ? _WaitingSection(weeklyTotal: driverProvider.weeklyTotal)
                          : _WeeklyChart(weeklyEarnings: driverProvider.weeklyEarnings),
                                  if (driverProvider.isOnline && driverProvider.incomingRequest == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextButton(
                            onPressed: () => driverProvider.simulateIncomingRequest(),
                            child: Text(
                              'Simulate: New Ride Request',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                if (driverProvider.incomingRequest != null)
                  NewRideRequestCard(
                    d: d,
                    request: driverProvider.incomingRequest!,
                    onAccept: () {
                      driverProvider.acceptRequest(auth.token).then((ok) {
                        if (!context.mounted || !ok) return;
                        final ride = driverProvider.activeRide;
                        if (ride == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DriverGoingToPickupScreen(ride: ride),
                          ),
                        );
                      });
                    },
                    onDecline: () {
                      driverProvider.declineRequest(auth.token);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.driverName,
    required this.vehicle,
    required this.d,
  });

  final String driverName;
  final String vehicle;
  final DriverUiStrings d;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.primaryTeal,
          child: Text(
            _initials(driverName),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driverName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                vehicle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DriverNotificationsScreen(),
                  ),
                );
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DriverProfileScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () async {
            final ok = await showSignOutConfirmDialog(
              context,
              message: d.signOutDialogMessage,
              cancelLabel: d.signOutDialogCancel,
              confirmLabel: d.signOutDialogConfirm,
            );
            if (!ok || !context.mounted) return;
            clearSessionProviders(context);
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => const ChooseRoleScreen(),
              ),
              (_) => false,
            );
          },
        ),
      ],
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.isOnline,
    required this.onToggle,
  });

  final bool isOnline;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOnline ? 'Online - Accepting rides' : 'Offline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOnline ? Colors.green.shade700 : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Switch(
            value: isOnline,
            onChanged: (_) => onToggle(),
            activeThumbColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.earnings,
    required this.trips,
    required this.onlineHours,
  });

  final int earnings;
  final int trips;
  final double onlineHours;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.attach_money,
            label: 'Earnings',
            value: formatLebanesePounds(earnings),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            icon: Icons.show_chart,
            label: 'Trips Today',
            value: '$trips',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            icon: Icons.access_time,
            label: 'Online Time',
            value: '${onlineHours}h',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppTheme.primaryTeal),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.weeklyEarnings});

  final List<int> weeklyEarnings;

  @override
  Widget build(BuildContext context) {
    final total = weeklyEarnings.fold(0, (a, b) => a + b);
    final maxEarning = weeklyEarnings.isEmpty ? 1 : weeklyEarnings.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                formatLebanesePounds(total),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .asMap()
                  .entries
                  .map((e) {
                final h = maxEarning > 0
                    ? (weeklyEarnings[e.key] / maxEarning * 70).clamp(4.0, 70.0)
                    : 4.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: h,
                      decoration: BoxDecoration(
                        color: weeklyEarnings[e.key] > 0
                            ? AppTheme.primaryTeal
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingSection extends StatelessWidget {
  const _WaitingSection({required this.weeklyTotal});

  final int weeklyTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                formatLebanesePounds(weeklyTotal),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Waiting for ride requests...',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
