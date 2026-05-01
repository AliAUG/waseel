import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/app_session_clear.dart';
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
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              driverProvider.isOnline ? 'ONLINE - ACCEPTING RIDES' : 'DRIVER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
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
                      _Header(driverName: driverName, vehicle: vehicle),
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
                      if (driverProvider.isOnline &&
                          driverProvider.incomingRequest == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: _DriverNotificationsSection(),
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

class _DriverNotificationItemData {
  const _DriverNotificationItemData({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.tag,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final String tag;
}

class _DriverNotificationsSection extends StatelessWidget {
  const _DriverNotificationsSection();

  static const List<_DriverNotificationItemData> _items = [
    _DriverNotificationItemData(
      title: 'New Ride Request',
      subtitle: 'Passenger near Hamra is requesting a ride.',
      timeAgo: '2 min ago',
      icon: Icons.directions_car,
      tag: 'Passenger',
    ),
    _DriverNotificationItemData(
      title: 'Delivery Pickup Update',
      subtitle: 'Package pickup confirmed in Achrafieh.',
      timeAgo: '8 min ago',
      icon: Icons.inventory_2,
      tag: 'Delivery',
    ),
    _DriverNotificationItemData(
      title: 'Passenger Message',
      subtitle: 'Passenger sent additional pickup notes.',
      timeAgo: '15 min ago',
      icon: Icons.chat_bubble_outline,
      tag: 'Passenger',
    ),
    _DriverNotificationItemData(
      title: 'Delivery Completed',
      subtitle: 'Delivery to Verdun was completed successfully.',
      timeAgo: '34 min ago',
      icon: Icons.task_alt,
      tag: 'Delivery',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                'Notifications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DriverNotificationsScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _DriverNotificationTile(
                item: item,
                onTap: () => _handleNotificationTap(context, item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    _DriverNotificationItemData item,
  ) async {
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (accepted != true) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Request rejected'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final driverProvider = context.read<DriverProvider>();
    final auth = context.read<AuthProvider>();
    driverProvider.simulateIncomingRequest();
    final ok = await driverProvider.acceptRequest(auth.token);
    if (!context.mounted) return;
    final ride = driverProvider.activeRide;
    if (!ok || ride == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Could not accept request. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverGoingToPickupScreen(ride: ride),
      ),
    );
  }
}

class _DriverNotificationTile extends StatelessWidget {
  const _DriverNotificationTile({
    required this.item,
    required this.onTap,
  });

  final _DriverNotificationItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 20, color: AppTheme.primaryTeal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.tag == 'Delivery'
                                ? Colors.orange.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.tag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.tag == 'Delivery'
                                  ? Colors.orange.shade800
                                  : Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item.timeAgo,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        const Spacer(),
                        Text(
                          'Tap to review',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.driverName,
    required this.vehicle,
  });

  final String driverName;
  final String vehicle;

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
                  color: Colors.grey.shade900,
                ),
              ),
              Text(
                vehicle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade800),
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
          icon: Icon(Icons.person_outline, color: Colors.grey.shade800),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DriverProfileScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.logout, color: Colors.grey.shade800),
          onPressed: () {
            clearSessionProviders(context);
            context.read<AuthProvider>().logout();
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
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOnline ? 'Online - Accepting rides' : 'Offline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOnline ? Colors.green.shade700 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
          Switch(
            value: isOnline,
            onChanged: (_) => onToggle(),
            activeColor: AppTheme.primaryTeal,
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
              color: Colors.grey.shade900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
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
                  color: Colors.grey.shade800,
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
                        color: Colors.grey.shade600,
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
                  color: Colors.grey.shade800,
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
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
