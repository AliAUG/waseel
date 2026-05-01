import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/user_settings_sync.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/edit_personal_info_screen.dart';
import 'package:waseel/features/passenger/screens/language_region_screen.dart';
import 'package:waseel/features/passenger/screens/about_screen.dart';
import 'package:waseel/features/passenger/screens/change_password_screen.dart';
import 'package:waseel/features/passenger/screens/privacy_policy_screen.dart';
import 'package:waseel/features/passenger/screens/terms_conditions_screen.dart';
import 'package:waseel/features/passenger/screens/notification_settings_screen.dart';
import 'package:waseel/features/passenger/screens/privacy_safety_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_settings_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await syncUserSettingsFromApi(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: scheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            final s = PassengerSettingsStrings(settings.language);
            return Text(
              s.settingsTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final s = PassengerSettingsStrings(settings.language);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(s.accountSecurity),
                _SettingsTile(
                  title: s.editPersonalInfo,
                  subtitle: s.editPersonalInfoSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditPersonalInfoScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: s.changePassword,
                  subtitle: s.changePasswordSub,
                  onTap: () {
                    final auth = context.read<AuthProvider>();
                    final t = auth.token;
                    final hasRealJwt =
                        t != null && t.isNotEmpty && t != 'local-session';
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChangePasswordScreen(
                          allowWithoutSession: !hasRealJwt,
                          initialEmail: auth.user?.email?.trim(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionTitle(s.appPreferences),
                _SettingsTile(
                  title: s.languageRegion,
                  subtitle: s.languageRegionSubtitle(settings.languageLabel),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LanguageRegionScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: s.notifications,
                  subtitle: s.notificationsSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: s.theme,
                  subtitle: settings.themeLabel,
                  trailing: const Icon(Icons.dark_mode_outlined, size: 20),
                  onTap: () async {
                    final next = settings.theme == AppThemeMode.light
                        ? AppThemeMode.dark
                        : AppThemeMode.light;
                    settings.setTheme(next);
                    final auth = context.read<AuthProvider>();
                    final ok = await settings.saveThemeToServer(auth.token);
                    if (!context.mounted) return;
                    if (!ok &&
                        auth.token != null &&
                        auth.token!.isNotEmpty &&
                        auth.token != 'local-session') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.couldNotSaveTheme)),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                _SectionTitle(s.privacyLegal),
                _SettingsTile(
                  title: s.privacySafety,
                  subtitle: s.privacySafetySub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacySafetyScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: s.terms,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TermsConditionsScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: s.privacyPolicy,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionTitle(s.aboutSection),
                _SettingsTile(
                  title: s.about,
                  subtitle: s.aboutSub,
                  trailing: const Icon(Icons.info_outline, size: 20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  },
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(12);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                          color: scheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  IconTheme(
                    data: IconThemeData(color: scheme.onSurfaceVariant),
                    child: trailing!,
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 20,
                  color: scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
