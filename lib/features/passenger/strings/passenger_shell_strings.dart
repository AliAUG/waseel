import 'package:waseel/features/passenger/providers/settings_provider.dart';

/// Bottom nav + passenger profile menu (follows [AppLanguage] from settings).
class PassengerShellStrings {
  PassengerShellStrings(this._lang);

  final AppLanguage _lang;

  bool get _ar => _lang == AppLanguage.arabic;

  String get navHome => _ar ? 'الرئيسية' : 'Home';
  String get navHistory => _ar ? 'السجل' : 'History';
  String get navWallet => _ar ? 'المحفظة' : 'Wallet';
  String get navProfile => _ar ? 'حسابي' : 'Profile';

  String get profileTitle => _ar ? 'ملف الراكب' : 'Passenger profile';

  String get myTrips => _ar ? 'رحلاتي' : 'My Trips';
  String get myTripsSub => _ar ? 'عرض سجل الرحلات' : 'View ride history';

  String get myDeliveries => _ar ? 'توصيلاتي' : 'My Deliveries';
  String get myDeliveriesSub => _ar ? 'عرض سجل التوصيل' : 'View delivery history';

  String get paymentMethods => _ar ? 'طرق الدفع' : 'Payment Methods';
  String get paymentMethodsSub =>
      _ar ? 'إدارة البطاقات والمحافظ' : 'Manage cards & wallets';

  String get savedPlaces => _ar ? 'الأماكن المحفوظة' : 'Saved Places';
  String get savedPlacesSub => _ar ? 'المنزل، العمل وغيرها' : 'Home, Work & more';

  String get settings => _ar ? 'الإعدادات' : 'Settings';

  String get helpSupport => _ar ? 'المساعدة والدعم' : 'Help & Support';
  String get helpSupportSub => _ar ? 'الأسئلة الشائعة والتواصل' : 'FAQ & contact';

  String get reportIncident => _ar ? 'بلاغ' : 'Report an issue';
  String get reportIncidentSub =>
      _ar ? 'مشكلة مع سائق بعد رحلة' : 'Problem with a driver after a trip';

  String get logout => _ar ? 'تسجيل الخروج' : 'Logout';

  String get signOutDialogMessage => _ar
      ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
      : 'Are you sure you want to sign out?';
  String get signOutDialogCancel => _ar ? 'إلغاء' : 'Cancel';
  String get signOutDialogConfirm => _ar ? 'تسجيل الخروج' : 'Sign out';

  String get versionLine => _ar ? 'الإصدار 1.0.0' : 'Version 1.0.0';

  String statTrips(int n) => _ar ? '$n رحلات' : '$n Trips';
  String statDeliveries(int n) => _ar ? '$n توصيلات' : '$n Deliveries';
}
