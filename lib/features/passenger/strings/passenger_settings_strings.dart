import 'package:waseel/features/passenger/providers/settings_provider.dart';

/// UI strings for Settings + Language screens (minimal i18n without full l10n codegen).
class PassengerSettingsStrings {
  PassengerSettingsStrings(this._lang);

  final AppLanguage _lang;

  bool get _ar => _lang == AppLanguage.arabic;

  String get settingsTitle => _ar ? 'الإعدادات' : 'Settings';
  String get accountSecurity => _ar ? 'الحساب والأمان' : 'Account & Security';
  String get editPersonalInfo => _ar ? 'تعديل المعلومات الشخصية' : 'Edit Personal Info';
  String get editPersonalInfoSub =>
      _ar ? 'الاسم، الهاتف، البريد' : 'Name, phone, email';
  String get changePassword => _ar ? 'تغيير كلمة المرور' : 'Change Password';
  String get changePasswordSub =>
      _ar ? 'تحديث كلمة المرور' : 'Update your password';
  String get changePasswordScreenTitle =>
      _ar ? 'تغيير كلمة المرور' : 'Change Password';
  String get changePasswordEmailHint =>
      _ar ? 'البريد المرتبط بحسابك' : 'Email linked to your account';
  String get changePasswordSendCode =>
      _ar ? 'إرسال رمز التحقق' : 'Send verification code';
  String get changePasswordCodeSent => _ar
      ? 'تم إرسال الرمز إلى بريدك'
      : 'Verification code sent to your email';
  String get changePasswordCodeHint =>
      _ar ? 'رمز من البريد' : 'Code from email';
  String get changePasswordNewHint =>
      _ar ? 'كلمة المرور الجديدة (6 أحرف على الأقل)' : 'New password (min 6 characters)';
  String get changePasswordConfirmHint =>
      _ar ? 'تأكيد كلمة المرور' : 'Confirm new password';
  String get changePasswordSubmit =>
      _ar ? 'تحديث كلمة المرور' : 'Update password';
  String get changePasswordNeedRealSession => _ar
      ? 'سجّل الدخول بحساب على السيرفر لتغيير كلمة المرور.'
      : 'Sign in with a server account to change your password.';
  String get changePasswordInvalidEmail =>
      _ar ? 'أدخل بريداً صالحاً' : 'Enter a valid email address';
  String get changePasswordMismatch =>
      _ar ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match';
  String get changePasswordTooShort =>
      _ar ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : 'Password must be at least 6 characters';
  String get changePasswordSuccess =>
      _ar ? 'تم تحديث كلمة المرور' : 'Password updated';
  String get appPreferences => _ar ? 'تفضيلات التطبيق' : 'App Preferences';
  String get languageRegion => _ar ? 'اللغة والمنطقة' : 'Language & Region';
  String get notifications => _ar ? 'الإشعارات' : 'Notifications';
  String get notificationsSub =>
      _ar ? 'إدارة التنبيهات والأصوات' : 'Manage alerts & sounds';
  String get theme => _ar ? 'المظهر' : 'Theme';
  String get privacyLegal => _ar ? 'الخصوصية والقانون' : 'Privacy & Legal';
  String get privacySafety => _ar ? 'الخصوصية والأمان' : 'Privacy & Safety';
  String get privacySafetySub =>
      _ar ? 'البيانات والأذونات' : 'Data & permissions';
  String get terms => _ar ? 'الشروط والأحكام' : 'Terms & Conditions';
  String get privacyPolicy => _ar ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get aboutSection => _ar ? 'عن التطبيق' : 'About This App';
  String get about => _ar ? 'حول' : 'About';
  String get aboutSub => _ar ? 'الإصدار 1.0.0' : 'Version 1.0.0';

  String get languageRegionScreenTitle =>
      _ar ? 'اللغة والمنطقة' : 'Language & Region';
  String get languageSection => _ar ? 'اللغة' : 'Language';
  String get englishTitle => 'English';
  String get englishSub => _ar ? 'اللغة الأساسية' : 'Primary language';
  String get arabicTitle => 'العربية';
  String get arabicSub => _ar ? 'اللغة العربية' : 'Arabic language';
  String get regionSection => _ar ? 'المنطقة' : 'Region';
  String get lebanon => _ar ? 'لبنان' : 'Lebanon';
  String get lebanonCurrencySub =>
      _ar ? 'العملة: ل.ل، دولار' : 'Currency: L.L, USD';
  String get languageHint => _ar
      ? 'تغيير اللغة يحدّث هذه الشاشات فوراً. باقي التطبيق يُترجم تدريجياً.'
      : 'Language changes apply to Settings flows immediately. More screens will follow.';
  String get saveChanges => _ar ? 'حفظ التغييرات' : 'Save Changes';
  /// Bottom action on Language & Region after instant sync on selection.
  String get languageRegionDone => _ar ? 'تم' : 'Done';
  String get couldNotSaveLanguage =>
      _ar ? 'تعذّر حفظ اللغة على السيرفر' : 'Could not save language on server';
  String get couldNotSaveTheme =>
      _ar ? 'تعذّر حفظ المظهر على السيرفر' : 'Could not save theme on server';

  String languageRegionSubtitle(String languageLabel) =>
      _ar ? '$languageLabel • لبنان' : '$languageLabel • Lebanon';
}
