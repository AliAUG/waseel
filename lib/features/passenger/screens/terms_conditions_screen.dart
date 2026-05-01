import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

class _TermsSection {
  const _TermsSection(this.title, this.body);
  final String title;
  final String body;
}

class _TermsCopy {
  _TermsCopy(this._ar);
  final bool _ar;

  String get screenTitle =>
      _ar ? 'الشروط والأحكام' : 'Terms & Conditions';
  String get lastUpdated => _ar
      ? 'آخر تحديث: ٦ نيسان ٢٠٢٦'
      : 'Last updated: April 6, 2026';

  List<_TermsSection> get sections => _ar ? _arSections : _enSections;
}

const List<_TermsSection> _enSections = [
  _TermsSection(
    '1. Agreement',
    'By accessing or using Waseel (RideGo) you agree to these Terms. If you do not agree, do not use the app.',
  ),
  _TermsSection(
    '2. The service',
    'Waseel connects passengers with drivers for rides and related services. Availability depends on drivers and network coverage. We do not guarantee uninterrupted service.',
  ),
  _TermsSection(
    '3. Accounts',
    'You must provide accurate information when registering. You are responsible for keeping your login credentials secure and for activity under your account.',
  ),
  _TermsSection(
    '4. Payments and wallet',
    'Charges, fees, and wallet top-ups follow the in-app payment rules and any applicable provider terms. Prices shown before you confirm a trip.',
  ),
  _TermsSection(
    '5. Safety and conduct',
    'Users must follow traffic laws and treat others respectfully. Harassment, fraud, or misuse of the platform may lead to suspension or termination.',
  ),
  _TermsSection(
    '6. Limitation of liability',
    'To the extent permitted by law, Waseel is not liable for indirect or consequential damages arising from use of the service. Nothing in these Terms limits liability that cannot be limited by law.',
  ),
  _TermsSection(
    '7. Changes',
    'We may update these Terms. Continued use after changes means you accept the updated Terms.',
  ),
  _TermsSection(
    '8. Contact',
    'Questions about these Terms: support@ridego.com.',
  ),
];

const List<_TermsSection> _arSections = [
  _TermsSection(
    '١. الموافقة',
    'باستخدامك لتطبيق وصيل (RideGo) فإنك توافق على هذه الشروط. إذا لم توافق، يُرجى عدم استخدام التطبيق.',
  ),
  _TermsSection(
    '٢. الخدمة',
    'يربط وصيل بين الركاب والسائقين لرحلات وخدمات ذات صلة. التوفر يعتمد على السائقين وشبكة الاتصال. لا نضمن خدمة دون انقطاع.',
  ),
  _TermsSection(
    '٣. الحسابات',
    'يجب تقديم معلومات صحيحة عند التسجيل. أنت مسؤول عن حماية بيانات الدخول وعن النشاط الذي يتم عبر حسابك.',
  ),
  _TermsSection(
    '٤. الدفع والمحفظة',
    'الرسوم والمحفظة تخضع لقواعد الدفع داخل التطبيق وشروط مزودي الدفع. تُعرض الأسعار قبل تأكيد الرحلة.',
  ),
  _TermsSection(
    '٥. السلامة والسلوك',
    'يلتزم المستخدمون بقوانين السير وباحترام الآخرين. قد يؤدي التحرش أو الاحتيال أو إساءة استخدام المنصة إلى تعليق أو إنهاء الحساب.',
  ),
  _TermsSection(
    '٦. حدود المسؤولية',
    'في الحدود التي يسمح بها القانون، لا يتحمل وصيل المسؤولية عن الأضرار غير المباشرة الناتجة عن استخدام الخدمة. لا يُقصد بهذه الشروط تقييد حقوقاً لا يجوز تقييدها قانوناً.',
  ),
  _TermsSection(
    '٧. التعديلات',
    'قد نحدّث هذه الشروط. استمرار الاستخدام بعد التعديل يعني موافقتك على النسخة المحدّثة.',
  ),
  _TermsSection(
    '٨. التواصل',
    'للأسئلة حول هذه الشروط: support@ridego.com.',
  ),
];

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ar =
        context.watch<SettingsProvider>().language == AppLanguage.arabic;
    final t = _TermsCopy(ar);

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
          t.screenTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              for (final s in t.sections) ...[
                Text(
                  s.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
