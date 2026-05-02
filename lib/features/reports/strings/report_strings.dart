import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/reports/models/report_category.dart';

class ReportStrings {
  ReportStrings(this._lang);

  final AppLanguage _lang;

  bool get _ar => _lang == AppLanguage.arabic;

  String get screenTitlePassenger =>
      _ar ? 'بلاغ عن سائق' : 'Report a driver';
  String get screenTitleDriver =>
      _ar ? 'بلاغ عن راكب' : 'Report a passenger';

  String get introPassenger => _ar
      ? 'صف المشكلة بعد رحلة أو توصيل. سيصل البلاغ لفريق الدعم للمراجعة.'
      : 'Describe an issue after a ride or delivery. Our team will review your report.';

  String get introDriver => _ar
      ? 'صف المشكلة مع راكب بعد مهمة. سيصل البلاغ لفريق الدعم.'
      : 'Describe an issue with a passenger after a job. Our team will review it.';

  String get linkTripLabel =>
      _ar ? 'ربط برحلة (اختياري)' : 'Link to trip (optional)';
  String get linkJobLabel =>
      _ar ? 'ربط بمهمة (اختياري)' : 'Link to job (optional)';
  String get noTripSelected =>
      _ar ? 'بدون — أدخل التفاصيل يدوياً' : 'None — describe manually';

  String get reportedNameLabelPassenger =>
      _ar ? 'اسم السائق (إن وُجد)' : 'Driver name (if known)';
  String get reportedNameLabelDriver =>
      _ar ? 'اسم الراكب أو رقم الهاتف' : 'Passenger name or phone';

  String get categoryLabel => _ar ? 'نوع البلاغ' : 'Report type';
  String get detailsLabel => _ar ? 'التفاصيل' : 'Details';
  String get detailsHint => _ar
      ? 'اشرح ما حصل بالتفصيل…'
      : 'Explain what happened in detail…';

  String get submit => _ar ? 'إرسال البلاغ' : 'Submit report';
  String get success =>
      _ar ? 'تم إرسال البلاغ. شكراً لك.' : 'Report sent. Thank you.';
  String get needLogin =>
      _ar ? 'سجّل الدخول لإرسال بلاغ.' : 'Sign in to submit a report.';
  String get detailsTooShort => _ar
      ? 'الرجاء كتابة تفاصيل أوضح (8 أحرف على الأقل).'
      : 'Please add more detail (at least 8 characters).';
  String get needReportedName => _ar
      ? 'أدخل اسم الشخص أو اختر رحلة مرتبطة.'
      : 'Enter the person\'s name or link a trip.';

  String categoryTitle(ReportCategory c) {
    switch (c) {
      case ReportCategory.safety:
        return _ar ? 'سلامة' : 'Safety';
      case ReportCategory.behavior:
        return _ar ? 'سلوك' : 'Behavior';
      case ReportCategory.paymentFare:
        return _ar ? 'دفع / أجرة' : 'Payment / fare';
      case ReportCategory.other:
        return _ar ? 'أخرى' : 'Other';
    }
  }

  String tripSummaryLine(String dateLine, String routeShort) =>
      '$dateLine · $routeShort';
}
