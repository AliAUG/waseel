import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/core/user_settings_sync.dart';
import 'package:waseel/features/passenger/providers/notification_settings_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

/// Notification preferences — local cache + `PUT /users/settings` when logged in.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          flow.notifSettingsTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, notif, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(flow.notifSectionRide),
                _ToggleTile(
                  title: flow.notifDriverAssigned,
                  subtitle: flow.notifDriverAssignedSub,
                  value: notif.driverAssigned,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setDriverAssigned,
                  ),
                ),
                _ToggleTile(
                  title: flow.notifDriverArrived,
                  subtitle: flow.notifDriverArrivedSub,
                  value: notif.driverArrived,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setDriverArrived,
                  ),
                ),
                _ToggleTile(
                  title: flow.notifTripStarted,
                  subtitle: flow.notifTripStartedSub,
                  value: notif.tripStarted,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setTripStarted,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(flow.notifSectionDelivery),
                _ToggleTile(
                  title: flow.notifPackagePickedUp,
                  subtitle: flow.notifPackagePickedUpSub,
                  value: notif.packagePickedUp,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setPackagePickedUp,
                  ),
                ),
                _ToggleTile(
                  title: flow.notifOutForDelivery,
                  subtitle: flow.notifOutForDeliverySub,
                  value: notif.outForDelivery,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setOutForDelivery,
                  ),
                ),
                _ToggleTile(
                  title: flow.notifDelivered,
                  subtitle: flow.notifDeliveredSub,
                  value: notif.delivered,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setDelivered,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(flow.notifSectionGeneral),
                _ToggleTile(
                  title: flow.notifPromotions,
                  subtitle: flow.notifPromotionsSub,
                  value: notif.promotionsOffers,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setPromotionsOffers,
                  ),
                ),
                _ToggleTile(
                  title: flow.notifSystem,
                  subtitle: flow.notifSystemSub,
                  value: notif.systemNotifications,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setSystemNotifications,
                  ),
                ),
                _ToggleTile(
                  title: flow.notifSound,
                  subtitle: flow.notifSoundSub,
                  value: notif.sound,
                  onChanged: notificationToggleWithSync(
                    context,
                    notif.setSound,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
