import 'package:flutter/material.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/passenger/models/package_size.dart';

enum DriverNotificationFilter { all, jobs, earnings, system }

class DriverNotification {
  const DriverNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.filter,
    this.isUnread = false,
  });

  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final DriverNotificationFilter filter;
  final bool isUnread;
}

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() =>
      _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  DriverNotificationFilter _filter = DriverNotificationFilter.all;
  final List<DriverNotification> _notifications = [];
  bool _allRead = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    _notifications.addAll([
      DriverNotification(
        id: '1',
        title: 'New Ride Request',
        description: 'Ride request from Sarah Ahmed in Tripoli City Center',
        timeAgo: '5 min ago',
        icon: Icons.directions_car,
        filter: DriverNotificationFilter.jobs,
        isUnread: true,
      ),
      DriverNotification(
        id: '2',
        title: 'Document Approved',
        description: 'Your insurance document has been approved',
        timeAgo: '2 hours ago',
        icon: Icons.description,
        filter: DriverNotificationFilter.system,
        isUnread: true,
      ),
      DriverNotification(
        id: '3',
        title: 'Weekly Earnings Summary',
        description:
            'You earned ${formatLebanesePounds(652000)} this week. Great job!',
        timeAgo: '1 day ago',
        icon: Icons.attach_money,
        filter: DriverNotificationFilter.earnings,
        isUnread: false,
      ),
      DriverNotification(
        id: '4',
        title: 'Delivery Completed',
        description: 'You completed delivery #DL-2025-001245',
        timeAgo: '1 day ago',
        icon: Icons.inventory_2,
        filter: DriverNotificationFilter.jobs,
        isUnread: false,
      ),
      DriverNotification(
        id: '5',
        title: 'Bonus Campaign',
        description: 'Complete 5 more rides today to earn 50,000 L.L bonus',
        timeAgo: '2 days ago',
        icon: Icons.attach_money,
        filter: DriverNotificationFilter.earnings,
        isUnread: false,
      ),
    ]);
  }

  List<DriverNotification> get _filtered {
    if (_filter == DriverNotificationFilter.all) return _notifications;
    return _notifications.where((n) => n.filter == _filter).toList();
  }

  void _markAllRead() {
    setState(() => _allRead = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              'Mark all read',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTeal,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DriverNotificationFilter.values.map((f) {
                  final isSelected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filterLabel(f)),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _filter = f),
                      selectedColor: AppTheme.primaryTeal,
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final n = _filtered[index];
                final showUnread = !_allRead && n.isUnread;
                return _NotificationCard(
                  icon: n.icon,
                  title: n.title,
                  description: n.description,
                  timeAgo: n.timeAgo,
                  isUnread: showUnread,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(DriverNotificationFilter f) {
    switch (f) {
      case DriverNotificationFilter.all:
        return 'All';
      case DriverNotificationFilter.jobs:
        return 'Jobs';
      case DriverNotificationFilter.earnings:
        return 'Earnings';
      case DriverNotificationFilter.system:
        return 'System';
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isUnread = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String timeAgo;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryTeal, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: AppTheme.primaryTeal,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
