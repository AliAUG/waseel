import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

/// Driver app copy tied to [AppLanguage] (same as passenger [SettingsProvider]).
class DriverUiStrings {
  DriverUiStrings(this._lang);

  final AppLanguage _lang;

  bool get _ar => _lang == AppLanguage.arabic;

  // —— Trip flow buttons ——
  String get startTrip => _ar ? 'بدء الرحلة' : 'Start Trip';
  String get completeTrip => _ar ? 'إكمال الرحلة' : 'Complete Trip';
  String get arrivedAtPickup => _ar ? 'وصلت لنقطة الاستلام' : 'Arrived at Pickup';
  String get finish => _ar ? 'إنهاء' : 'Finish';
  String get goingToPickupAppBar =>
      _ar ? 'في الطريق للاستلام' : 'GOING TO PICKUP';
  String get finishAppBar => _ar ? 'إنهاء' : 'FINISH';

  String get tripStatusFailed =>
      _ar ? 'تعذّر تحديث حالة الرحلة.' : 'Could not update trip status.';

  // —— Job history ——
  String get jobHistoryTitle => _ar ? 'سجل المهام' : 'Job History';
  String statTotalJobs(int n) =>
      _ar ? '$n مهام' : '$n Total jobs';
  String statAvgRating(double r) =>
      _ar ? '★$r متوسط التقييم' : '★$r Avg rating';
  String statAcceptance(int p) =>
      _ar ? '$p٪ قبول' : '$p% Acceptance';
  String get filterAll => _ar ? 'الكل' : 'All';
  String get filterRides => _ar ? 'رحلات' : 'Rides';
  String get filterDeliveries => _ar ? 'توصيل' : 'Deliveries';
  String get filterCompleted => _ar ? 'مكتمل' : 'Completed';
  String get noJobsFound => _ar ? 'لا توجد مهام' : 'No jobs found';
  String get jobCanceled => _ar ? 'ملغاة' : 'Canceled';
  String get jobCompleted => _ar ? 'مكتمل' : 'Completed';

  String jobFilterLabel(JobFilter f) {
    switch (f) {
      case JobFilter.all:
        return filterAll;
      case JobFilter.rides:
        return filterRides;
      case JobFilter.deliveries:
        return filterDeliveries;
      case JobFilter.completed:
        return filterCompleted;
    }
  }

  // —— Earnings ——
  String get earningsWalletEyebrow =>
      _ar ? 'الأرباح والمحفظة' : 'EARNINGS & WALLET';
  String get earningsWalletTitle =>
      _ar ? 'الأرباح والمحفظة' : 'Earnings & Wallet';
  String get totalBalance => _ar ? 'الرصيد الإجمالي' : 'Total Balance';
  String get requestPayout => _ar ? 'طلب سحب' : 'Request Payout';
  String get today => _ar ? 'اليوم' : 'Today';
  String get thisWeek => _ar ? 'هذا الأسبوع' : 'This Week';
  String vsYesterdayPositive(int p) =>
      _ar ? '+$p٪ مقارنة بالأمس' : '+$p% vs yesterday';
  String vsYesterdayNegative(int p) =>
      _ar ? '$p٪ مقارنة بالأمس' : '$p% vs yesterday';
  String daysLeft(int n) =>
      _ar ? '$n أيام متبقية' : '$n days left';
  String get weeklyEarnings => _ar ? 'أرباح الأسبوع' : 'Weekly Earnings';
  String get transactionHistory =>
      _ar ? 'سجل الحركات' : 'Transaction History';
  String get noTransactionsYet =>
      _ar ? 'لا حركات بعد' : 'No transactions yet';
  String get paid => _ar ? 'مدفوع' : 'Paid';
  String weeklyJobsStat(int n) =>
      _ar ? '$n مهام' : '$n Total jobs';
  String weeklyRidesStat(int n) =>
      _ar ? '$n رحلات' : '$n Rides';
  String weeklyDeliveriesStat(int n) =>
      _ar ? '$n توصيل' : '$n Deliveries';

  String earningsFilterLabel(EarningsFilter f) {
    switch (f) {
      case EarningsFilter.all:
        return filterAll;
      case EarningsFilter.rides:
        return filterRides;
      case EarningsFilter.deliveries:
        return filterDeliveries;
      case EarningsFilter.pending:
        return _ar ? 'قيد الانتظار' : 'Pending';
    }
  }

  // —— Request payout ——
  String get reqPayoutEyebrow => _ar ? 'طلب سحب' : 'REQ PAYOUT';
  String get requestPayoutTitle => _ar ? 'طلب سحب' : 'Request Payout';
  String get availableBalance =>
      _ar ? 'الرصيد المتاح' : 'Available Balance';
  String get withdrawalAmount => _ar ? 'مبلغ السحب' : 'Withdrawal Amount';
  String minWithdrawalLine(String formatted) => _ar
      ? 'الحد الأدنى للسحب: $formatted'
      : 'Minimum withdrawal: $formatted';
  String get payoutMethod => _ar ? 'طريقة السحب' : 'Payout Method';
  String get wishMoney => _ar ? 'ويش موني' : 'Wish Money';
  String get wishMoneyTransferSub => _ar
      ? 'تحويل إلى محفظة ويش موني'
      : 'Transfer to Wish Money wallet';
  String get instantTransfer => _ar ? 'تحويل فوري' : 'Instant transfer';
  String get payoutInstantBlurb => _ar
      ? 'تُحوَّل أرباحك فوراً إلى حساب ويش موني المرتبط.'
      : 'Your earnings will be transferred instantly to your linked Wish Money account.';
  String get payoutInfoBanner => _ar
      ? 'تُعالَج المدفوعات عبر ويش موني فوراً. ستصلك إشعاراً عند اكتمال التحويل.'
      : 'Payouts via Wish Money are processed instantly. You\'ll receive a notification once the transfer is complete.';
  String get withdrawalAmountSummary =>
      _ar ? 'مبلغ السحب:' : 'Withdrawal amount:';
  String get processingFeeSummary =>
      _ar ? 'رسوم المعالجة:' : 'Processing fee:';
  String get youWillReceiveSummary =>
      _ar ? 'ستستلم:' : 'You\'ll receive:';
  String get remainingBalanceSummary =>
      _ar ? 'الرصيد المتبقي:' : 'Remaining balance:';
  String get confirmWithdrawal =>
      _ar ? 'تأكيد السحب' : 'Confirm Withdrawal';
  String get viewPayoutHistory =>
      _ar ? 'عرض سجل السحوبات' : 'View Payout History';
  String get payoutHistoryScreenTitle =>
      _ar ? 'سجل السحوبات' : 'Payout History';
  String get payoutHistoryEmpty =>
      _ar ? 'لا توجد سحوبات بعد' : 'No withdrawals yet';
  String get payoutHistoryLoadError =>
      _ar ? 'تعذّر تحميل السجل' : 'Could not load history';
  String get payoutHistoryNeedLogin =>
      _ar ? 'سجّل الدخول بحساب السائق على السيرفر لعرض السجل.'
      : 'Sign in with your driver account to view history.';
  String minWithdrawalSnack(String formatted) => _ar
      ? 'الحد الأدنى للسحب $formatted'
      : 'Minimum withdrawal is $formatted';
  String get exceedsBalanceSnack =>
      _ar ? 'المبلغ يتجاوز الرصيد المتاح' : 'Amount exceeds available balance';
  String get payoutFailed =>
      _ar ? 'تعذّر السحب. حاول مرة ثانية.' : 'Could not complete payout. Try again.';

  // —— Payout success ——
  String get payoutSuccessEyebrow =>
      _ar ? 'تم طلب السحب' : 'PAYOUT SUCCESS';
  String get payoutSuccessTitle =>
      _ar ? 'نجاح طلب السحب' : 'Payout Success';
  String get payoutRequestedHeadline => _ar
      ? 'تم إرسال طلب السحب بنجاح!'
      : 'Payout Requested Successfully!';
  String payoutRequestedBody(String amountFormatted) => _ar
      ? 'سحبك بقيمة $amountFormatted قيد المعالجة عبر ويش موني.'
      : 'Your withdrawal of $amountFormatted is being processed via Wish Money.';
  String get remainingBalance => _ar ? 'الرصيد المتبقي' : 'Remaining Balance';
  String get transactionIdLabel =>
      _ar ? 'رقم العملية' : 'Transaction ID';
  String get payoutMethodLabel =>
      _ar ? 'طريقة السحب' : 'Payout Method';
  String get processingTimeLabel =>
      _ar ? 'مدة المعالجة' : 'Processing Time';
  String get processingInstant => _ar ? 'فوري' : 'Instant';
  String get dateTimeLabel => _ar ? 'التاريخ والوقت' : 'Date & Time';
  String get payoutSuccessFooter => _ar
      ? 'ستُحوَّل أرباحك إلى محفظة ويش موني فوراً. ستصلك إشعاراً عند الاكتمال.'
      : 'Your earnings will be transferred to your Wish Money wallet instantly. You\'ll receive a notification once completed.';
  String get backToEarnings =>
      _ar ? 'العودة للأرباح' : 'Back to Earnings';

  // —— Trip detail cards ——
  String get fareLabel => _ar ? 'الأجرة' : 'Fare';
  String get pickupLocationLabel =>
      _ar ? 'نقطة الاستلام' : 'Pickup Location';
  String get dropoffLocationLabel =>
      _ar ? 'نقطة النزول' : 'Drop-off Location';
  String get pickupPointShort => _ar ? 'الاستلام' : 'Pickup';
  String get dropoffPointShort => _ar ? 'التوصيل' : 'Drop-off';
  String get fromLabel => _ar ? 'من' : 'From';
  String get passengerSectionTitle => _ar ? 'الراكب' : 'Passenger';
  String passengerRatingLine(double r) =>
      _ar ? 'تقييم $r' : '$r rating';
  String get statusGoingToPickup =>
      _ar ? 'في الطريق للاستلام' : 'Going to pickup';
  String get statusArrivedAtPickup =>
      _ar ? 'وصلت لنقطة الاستلام' : 'Arrived at pickup';
  String get subtextWaiting => _ar ? 'بانتظار' : 'Waiting';
  String etaMinutes(int n) => _ar ? '$n د' : '$n min';
  String get statusTripInProgress =>
      _ar ? 'الرحلة جارية' : 'Trip in progress';
  String get statusTripCompleted =>
      _ar ? 'اكتملت الرحلة' : 'Trip completed';
  String get tripCompletedSuccessHeadline => _ar
      ? 'اكتملت الرحلة بنجاح!'
      : 'Trip Completed Successfully!';
  String paymentReceivedLine(String amountFormatted) => _ar
      ? 'تم استلام الدفع: $amountFormatted'
      : 'Payment received: $amountFormatted';
  String routeFromAddress(String address) =>
      _ar ? 'من $address' : 'From $address';

  // —— Incoming ride request sheet ——
  String get newRideRequestTitle =>
      _ar ? 'طلب رحلة جديد' : 'New Ride Request';
  String tripsCountLabel(int n) =>
      _ar ? '$n رحلات' : '$n trips';
  String get estimatedFareLabel =>
      _ar ? 'أجرة تقديرية' : 'Estimated Fare';
  String get declineRide => _ar ? 'رفض' : 'Decline';
  String get acceptRide => _ar ? 'قبول' : 'Accept';
}
