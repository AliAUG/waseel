import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/driver/providers/driver_settings_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/about_screen.dart';
import 'package:waseel/features/passenger/screens/edit_personal_info_screen.dart';
import 'package:waseel/features/passenger/screens/language_region_screen.dart';
import 'package:waseel/features/passenger/screens/privacy_policy_screen.dart';
import 'package:waseel/features/passenger/screens/privacy_safety_screen.dart';
import 'package:waseel/features/passenger/screens/terms_conditions_screen.dart';

class DriverSettingsScreen extends StatelessWidget {
  const DriverSettingsScreen({super.key});

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
        title: Column(
          children: [
            Text(
              'DRIVER SETTING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer2<SettingsProvider, DriverSettingsProvider>(
        builder: (context, settings, driverSettings, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsTile(
                  title: 'Edit Personal Info',
                  subtitle: 'Name, email, profile photo',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditPersonalInfoScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: 'Language',
                  subtitle: settings.languageLabel,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LanguageRegionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _ToggleTile(
                  title: 'Job Alerts',
                  subtitle: 'Get notified about new jobs',
                  value: driverSettings.jobAlerts,
                  onChanged: driverSettings.setJobAlerts,
                ),
                _ToggleTile(
                  title: 'Promotions',
                  subtitle: 'Bonuses and special offers',
                  value: driverSettings.promotions,
                  onChanged: driverSettings.setPromotions,
                ),
                _ToggleTile(
                  title: 'System Messages',
                  subtitle: 'Updates and announcements',
                  value: driverSettings.systemMessages,
                  onChanged: driverSettings.setSystemMessages,
                ),
                _ToggleTile(
                  title: 'Sound',
                  subtitle: 'Alert sounds for new jobs',
                  value: driverSettings.sound,
                  onChanged: driverSettings.setSound,
                ),
                const SizedBox(height: 24),
                _SettingsTile(
                  title: 'Privacy & Safety',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacySafetyScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: 'About',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TermsConditionsScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'RideGo Driver v1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
