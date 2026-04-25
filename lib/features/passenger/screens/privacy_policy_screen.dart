import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

class _PrivacySection {
  const _PrivacySection(this.title, this.body);
  final String title;
  final String body;
}

class _PrivacyCopy {
  _PrivacyCopy(this._ar);
  final bool _ar;

  String get screenTitle =>
      _ar ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get lastUpdated => _ar
      ? 'آخر تحديث: ٦ نيسان ٢٠٢٦'
      : 'Last updated: April 6, 2026';

  List<_PrivacySection> get sections => _ar ? _arSections : _enSections;
}

const List<_PrivacySection> _enSections = [
  _PrivacySection(
    '1. Overview',
    'This policy describes how Waseel (RideGo) collects, uses, and protects your information when you use our mobile app and related services.',
  ),
  _PrivacySection(
    '2. Information we collect',
    'We may collect account details (name, phone, email), trip and delivery information, approximate or precise location when you use location features, device and log data, and communications with support.',
  ),
  _PrivacySection(
    '3. How we use information',
    'We use data to provide and improve rides and deliveries, match passengers and drivers, process payments and wallet activity, send service-related messages, ensure safety, and comply with law.',
  ),
  _PrivacySection(
    '4. Sharing',
    'We may share information with drivers and passengers as needed to complete a trip, with payment and infrastructure providers, and when required by law or to protect rights and safety. We do not sell your personal data.',
  ),
  _PrivacySection(
    '5. Retention',
    'We keep information as long as needed to operate the service, meet legal obligations, and resolve disputes. Some data may be retained in anonymized form.',
  ),
  _PrivacySection(
    '6. Security',
    'We use reasonable technical and organizational measures to protect your data. No method of transmission over the internet is completely secure.',
  ),
  _PrivacySection(
    '7. Your choices',
    'You may update profile information in the app, adjust notification and privacy settings where available, and contact us for questions about your data.',
  ),
  _PrivacySection(
    '8. Contact',
    'Privacy questions: privacy@ridego.com.',
  ),
];

const List<_PrivacySection> _arSections = [
  _PrivacySection(
    '١. نظرة عامة',
    'تشرح هذه السياسة كيفية جمع وصيل (RideGo) لمعلوماتك واستخدامها وحمايتها عند استخدام التطبيق والخدمات المرتبطة.',
  ),
  _PrivacySection(
    '٢. المعلومات التي نجمعها',
    'قد نجمع بيانات الحساب (الاسم، الهاتف، البريد)، معلومات الرحلات والتوصيل، الموقع التقريبي أو الدقيق عند تفعيل الميزات، بيانات الجهاز والسجلات، ومراسلات الدعم.',
  ),
  _PrivacySection(
    '٣. كيفية الاستخدام',
    'نستخدم البيانات لتقديم الرحلات والتوصيل وتحسينها، وربط الركاب بالسائقين، ومعالجة الدفع والمحفظة، وإرسال رسائل الخدمة، وضمان السلامة، والالتزام بالقانون.',
  ),
  _PrivacySection(
    '٤. المشاركة',
    'قد نشارك المعلومات مع السائقين والركاب لإتمام الرحلة، ومع مزودي الدفع والبنية التحتية، وعند الاقتضاء قانوناً أو لحماية الحقوق والسلامة. لا نبيع بياناتك الشخصية.',
  ),
  _PrivacySection(
    '٥. الاحتفاظ',
    'نحتفظ بالمعلومات ما دامت لازمة لتشغيل الخدمة والالتزامات القانونية وحل النزاعات. قد يُحتفظ ببعض البيانات بشكل مجهّل.',
  ),
  _PrivacySection(
    '٦. الأمان',
    'نستخدم تدابير تقنية وتنظيمية معقولة لحماية بياناتك. لا يوجد نقل عبر الإنترنت آمن بالكامل.',
  ),
  _PrivacySection(
    '٧. خياراتك',
    'يمكنك تحديث الملف في التطبيق، وتعديل إعدادات الإشعارات والخصوصية حيث تتوفر، والتواصل معنا لاستفسارات حول بياناتك.',
  ),
  _PrivacySection(
    '٨. التواصل',
    'للأسئلة حول الخصوصية: privacy@ridego.com.',
  ),
];

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ar =
        context.watch<SettingsProvider>().language == AppLanguage.arabic;
    final t = _PrivacyCopy(ar);

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
          t.screenTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.lastUpdated,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              for (final s in t.sections) ...[
                Text(
                  s.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
