import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/backend_config.dart';
import 'package:waseel/core/network/health_api_service.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/privacy_policy_screen.dart';
import 'package:waseel/features/passenger/screens/terms_conditions_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutCopy {
  _AboutCopy(this._ar);
  final bool _ar;

  String get aboutTitle => _ar ? 'حول' : 'About';
  String get serverStatus => _ar ? 'حالة السيرفر' : 'Server status';
  String get apiBase => _ar ? 'عنوان الـ API' : 'API base URL';
  String get checking => _ar ? 'جاري التحقق…' : 'Checking…';
  String get connected => _ar ? 'متصل' : 'Connected';
  String get unreachable => _ar ? 'غير متاح' : 'Unreachable';
  String get retry => _ar ? 'إعادة المحاولة' : 'Retry';
  String get terms => _ar ? 'الشروط والأحكام' : 'Terms & Conditions';
  String get privacy => _ar ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get licenses => _ar ? 'التراخيص' : 'Licenses';
  String get website => _ar ? 'الموقع' : 'Website';
  String get contactUs => _ar ? 'تواصل معنا' : 'Contact Us';
  String get supportEmail => _ar ? 'البريد للدعم' : 'Support Email';
  String get rights => _ar ? '© 2024 RideGo. جميع الحقوق محفوظة.' : '© 2024 RideGo. All rights reserved.';
  String get madeIn => _ar ? 'صُنع بـ ❤️ في لبنان' : 'Made with ❤️ in Lebanon';
  String get versionLine => _ar ? 'الإصدار 1.0.0' : 'Version 1.0.0';
  String get buildLine => _ar ? 'البنية 100' : 'Build 100';
}

class _AboutScreenState extends State<AboutScreen> {
  final _health = HealthApiService();
  bool _loading = true;
  Map<String, dynamic>? _healthBody;

  @override
  void initState() {
    super.initState();
    _ping();
  }

  Future<void> _ping() async {
    setState(() {
      _loading = true;
      _healthBody = null;
    });
    final body = await _health.fetchHealth();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _healthBody = body;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<SettingsProvider>().language == AppLanguage.arabic;
    final t = _AboutCopy(ar);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.aboutTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'RideGo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.versionLine,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              t.buildLine,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            _ServerStatusCard(
              t: t,
              loading: _loading,
              healthBody: _healthBody,
              onRetry: _ping,
            ),
            const SizedBox(height: 16),
            _LinkTile(
              icon: Icons.description_outlined,
              title: t.terms,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TermsConditionsScreen(),
                  ),
                );
              },
            ),
            _LinkTile(
              icon: Icons.shield_outlined,
              title: t.privacy,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _LinkTile(
              icon: Icons.description_outlined,
              title: t.licenses,
              onTap: () {},
            ),
            _LinkTile(
              icon: Icons.language_outlined,
              title: t.website,
              subtitle: 'www.ridego.com',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.contactUs,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _LinkTile(
              icon: Icons.email_outlined,
              title: t.supportEmail,
              subtitle: 'support@ridego.com',
              onTap: () {},
            ),
            const SizedBox(height: 48),
            Text(
              t.rights,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.madeIn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerStatusCard extends StatelessWidget {
  const _ServerStatusCard({
    required this.t,
    required this.loading,
    required this.healthBody,
    required this.onRetry,
  });

  final _AboutCopy t;
  final bool loading;
  final Map<String, dynamic>? healthBody;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ok = healthBody != null &&
        (healthBody!['status']?.toString().toLowerCase() == 'ok');
    final service = healthBody?['service']?.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.serverStatus,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.apiBase,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            BackendConfig.baseUrl,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          if (loading)
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  t.checking,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  ok ? Icons.check_circle : Icons.error_outline,
                  size: 22,
                  color: ok ? Colors.green.shade600 : Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ok ? t.connected : t.unreachable,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      if (ok && service != null && service.isNotEmpty)
                        Text(
                          service,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: Text(t.retry),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
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
            Icon(icon, color: Colors.grey.shade700, size: 24),
            const SizedBox(width: 16),
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              rtl ? Icons.chevron_left : Icons.chevron_right,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
