import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

class _FaqItem {
  const _FaqItem(this.question, this.answer);
  final String question;
  final String answer;
}

class _HelpCopy {
  _HelpCopy(this._ar);
  final bool _ar;

  String get title => _ar ? 'المساعدة والدعم' : 'Help & Support';
  String get intro => _ar
      ? 'إليك إجابات سريعة وطريقة التواصل مع فريق الدعم.'
      : 'Quick answers and how to reach our support team.';

  String get faqSectionTitle =>
      _ar ? 'أسئلة شائعة' : 'Frequently asked questions';

  List<_FaqItem> get faqs => _ar ? _arFaqs : _enFaqs;

  String get contactTitle => _ar ? 'تواصل معنا' : 'Contact us';
  String get supportEmail => 'support@ridego.com';
  String get copyEmail => _ar ? 'نسخ البريد' : 'Copy email';
  String get copied => _ar ? 'تم النسخ' : 'Copied';
}

const List<_FaqItem> _enFaqs = [
  _FaqItem(
    'How do I book a ride?',
    'Open Home, set your pickup and destination, choose a ride type, then confirm. You can track the driver on the map.',
  ),
  _FaqItem(
    'How do payments work?',
    'You can use your in-app wallet and saved payment methods where available. Charges are shown before you confirm a trip.',
  ),
  _FaqItem(
    'I can\'t sign in or I forgot my password',
    'Use Change Password in Settings with your account email to receive a verification code, or reset via the login flow when available.',
  ),
];

const List<_FaqItem> _arFaqs = [
  _FaqItem(
    'كيف أطلب رحلة؟',
    'من الرئيسية حدّد الانطلاق والوجهة ونوع الرحلة ثم أكّد. يمكنك تتبع السائق على الخريطة.',
  ),
  _FaqItem(
    'كيف يعمل الدفع؟',
    'يمكنك استخدام المحفظة داخل التطبيق وطرق الدفع المحفوظة حيث تتوفر. تظهر الرسوم قبل تأكيد الرحلة.',
  ),
  _FaqItem(
    'لا أستطيع تسجيل الدخول أو نسيت كلمة المرور',
    'استخدم «تغيير كلمة المرور» من الإعدادات مع بريد حسابك لاستلام رمز التحقق.',
  ),
];

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ar =
        context.watch<SettingsProvider>().language == AppLanguage.arabic;
    final t = _HelpCopy(ar);

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
          t.title,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              t.intro,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.faqSectionTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...t.faqs.map(
              (f) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  title: Text(
                    f.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: ar
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        f.answer,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.contactTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: t.supportEmail));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.copied)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, color: AppTheme.primaryTeal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SelectableText(
                          t.supportEmail,
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        t.copyEmail,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
