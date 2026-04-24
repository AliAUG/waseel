import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/models/saved_place.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

/// Home (ride), wallet, and trip history copy tied to [AppLanguage].
class PassengerFlowStrings {
  PassengerFlowStrings(this._lang);

  final AppLanguage _lang;

  bool get _ar => _lang == AppLanguage.arabic;
  bool get isArabic => _ar;

  // —— Ride home ——
  String get homeTitle => _ar ? 'الرئيسية' : 'Home';
  String get searchHintRide => _ar ? 'إلى وين بلبنان؟' : 'Where to in Lebanon?';
  String get searchHintDelivery =>
      _ar ? 'عناوين الاستلام والتسليم بلبنان' : 'Pickup & drop-off addresses in Lebanon';
  String get pillRide => _ar ? 'رحلة' : 'Ride';
  String get pillDelivery => _ar ? 'توصيل' : 'Delivery';
  String get chooseRide => _ar ? 'اختر نوع الرحلة' : 'Choose a ride';
  String get choosePackageSize => _ar ? 'اختر حجم الطرد' : 'Choose package size';

  String offlineRideTypesError(String err) =>
      _ar ? 'استخدام أسعار محلية ($err)' : 'Using offline prices ($err)';

  String packageTitle(PackageSize size) {
    switch (size) {
      case PackageSize.small:
        return _ar ? 'طرد صغير' : 'Small package';
      case PackageSize.medium:
        return _ar ? 'طرد متوسط' : 'Medium package';
      case PackageSize.large:
        return _ar ? 'طرد كبير' : 'Large package';
    }
  }

  String packageWeight(PackageSize size) {
    switch (size) {
      case PackageSize.small:
        return _ar ? 'حتى 5' : 'Under 5';
      case PackageSize.medium:
        return _ar ? 'من 5 حتى 30' : 'Up to 5 till 30';
      case PackageSize.large:
        return _ar ? 'من 30 حتى 100' : 'Up to 30 till 100';
    }
  }

  String deliveryEtaLine(PackageSize size, double distanceKm) =>
      deliveryEtaRange(size, distanceKm, arabic: _ar);

  // —— Wallet ——
  String get walletTitle => _ar ? 'المحفظة' : 'Wallet';
  String get availableBalance => _ar ? 'الرصيد المتاح' : 'Available Balance';
  String get addBalance => _ar ? 'إضافة رصيد' : 'Add Balance';
  String get walletPaymentMethods => _ar ? 'طرق الدفع' : 'Payment Methods';
  String get recentTransactions => _ar ? 'آخر الحركات' : 'Recent Transactions';
  String get walletAllTransactionsTitle =>
      _ar ? 'جميع الحركات' : 'Transactions';
  String get seeAll => _ar ? 'عرض الكل' : 'See all';
  String get noTransactionsYet => _ar ? 'لا توجد حركات بعد' : 'No transactions yet';

  // —— Trip / delivery history ——
  String get historyAppBar => _ar ? 'السجل' : 'History';
  String get deliveriesAppBar => _ar ? 'التوصيلات' : 'Deliveries';
  String get tripHistoryTitle => _ar ? 'سجل الرحلات' : 'Trip History';
  String get tripHistorySubtitle => _ar ? 'رحلاتك الأخيرة' : 'Your recent rides';
  String get deliveryHistoryTitle => _ar ? 'سجل التوصيل' : 'Delivery History';
  String get deliveryHistorySubtitle =>
      _ar ? 'طرودك المسلّمة' : 'Your package deliveries';
  String get loginToSeeHistory => _ar
      ? 'سجّل الدخول بالبريد الإلكتروني لعرض السجل.'
      : 'Sign in with email to view your history.';
  String get retry => _ar ? 'إعادة المحاولة' : 'Retry';
  String get emptyTrips => _ar ? 'لا توجد رحلات بعد.' : 'No trips yet.';
  String get emptyDeliveries => _ar ? 'لا توجد توصيلات بعد.' : 'No deliveries yet.';

  // —— Send package ——
  String get sendPackageTitle => _ar ? 'إرسال طرد' : 'Send a Package';
  String get addressesLebanonOnly =>
      _ar ? 'كل العناوين يجب أن تكون داخل لبنان' : 'All addresses must be within Lebanon';
  String get pickupAddressLabel => _ar ? 'عنوان الاستلام' : 'Pickup Address';
  String get pickupAddressHint =>
      _ar ? 'أدخل عنوان الاستلام في لبنان' : 'Enter pickup address in Lebanon';
  String get dropoffAddressLabel => _ar ? 'عنوان التسليم' : 'Drop-off Address';
  String get dropoffAddressHint =>
      _ar ? 'أدخل عنوان التسليم في لبنان' : 'Enter drop-off address in Lebanon';
  String get packageSizeSection => _ar ? 'حجم الطرد' : 'Package Size';
  String get additionalNotes => _ar ? 'ملاحظات إضافية (اختياري)' : 'Additional Notes (Optional)';
  String get notesHint =>
      _ar ? 'أي تعليمات خاصة بالتوصيل…' : 'Add any special instructions...';
  String get estimatedDelivery => _ar ? 'وقت التوصيل التقريبي' : 'Estimated delivery';
  String get deliveryFeeLabel => _ar ? 'أجرة التوصيل' : 'Delivery Fee';
  String get requestDelivery => _ar ? 'طلب التوصيل' : 'Request Delivery';

  String sendPackageEtaRange(int low, int high) =>
      _ar ? '$low–$high دقيقة' : '$low–$high min';

  String packageSizeShort(PackageSize size) {
    switch (size) {
      case PackageSize.small:
        return _ar ? 'صغير' : 'Small';
      case PackageSize.medium:
        return _ar ? 'متوسط' : 'Medium';
      case PackageSize.large:
        return _ar ? 'كبير' : 'Large';
    }
  }

  // —— Select location (ride) ——
  String get selectLocationAppBar => _ar ? 'اختيار الموقع' : 'Select location';
  String get selectRideBookingAppBar => _ar ? 'حجز رحلة' : 'Book a ride';
  String get pickupFieldLabel => _ar ? 'موقع الانطلاق (لبنان)' : 'Current Location (Lebanon)';
  String get destinationFieldLabel => _ar ? 'إلى أين؟ (لبنان)' : 'Where to? (Lebanon)';
  String get confirmRide => _ar ? 'تأكيد الرحلة' : 'Confirm Ride';
  String get locationSearchPickupTitle => _ar ? 'موقع الانطلاق' : 'Pickup location';
  String get locationSearchDestinationTitle => _ar ? 'الوجهة' : 'Destination';
  String get currentLocationLebanon =>
      _ar ? 'موقعي الحالي، لبنان' : 'Current Location, Lebanon';

  String get tripRequiresEmailLogin => _ar
      ? 'يجب تسجيل الدخول بالبريد لإنشاء رحلة.'
      : 'Sign in with email to create a trip.';
  String get pleaseSelectRideType =>
      _ar ? 'يرجى اختيار نوع الرحلة.' : 'Please select a ride type.';
  String get rideTypeServerConfigError => _ar
      ? 'تعذر تحديد نوع الرحلة. تأكد أن السيرفر يعمل وأن البيانات مهيأة.'
      : 'Could not resolve ride type. Ensure the server is running and data is seeded.';

  // —— Location search ——
  String get locationSearchHint =>
      _ar ? 'ابحث عن مكان في لبنان…' : 'Search location in Lebanon...';
  String get useMyCurrentLocation => _ar ? 'استخدام موقعي الحالي' : 'Use my current location';
  String get noLocationsFound => _ar ? 'لا نتائج' : 'No locations found';
  String get locationPermissionRequired =>
      _ar ? 'يلزم إذن الموقع' : 'Location permission is required';
  String get enableLocationServices =>
      _ar ? 'فعّل خدمات الموقع' : 'Please enable location services';
  String get couldNotGetLocation =>
      _ar ? 'تعذر جلب الموقع الحالي' : 'Could not get current location';

  // —— Searching driver / delivery ——
  String get searchDriverAppBar =>
      _ar ? 'البحث عن سائق' : 'Search for a driver';
  String get searchingDeliveryAppBar =>
      _ar ? 'جاري طلب التوصيل' : 'Searching for delivery';
  String get findingDriver =>
      _ar ? 'عم ندورلك على سائق…' : 'Finding you a driver...';
  String get usuallyUnderMinute => _ar
      ? 'عادة بياخد أقل من دقيقة.'
      : 'This usually takes less than a minute.';
  String get simulateDriverFound =>
      _ar ? 'محاكاة: تم إيجاد سائق' : 'Simulate: Driver Found';
  String get tripMissingIdError =>
      _ar ? 'معرّف الرحلة غير متوفر.' : 'Trip id is missing.';
  String get tripCancelledDuringSearch =>
      _ar ? 'تم إلغاء الرحلة.' : 'This trip was cancelled.';
  String get sendingDeliveryRequest =>
      _ar ? 'عم نرسل طلب التوصيل…' : 'Sending your delivery request…';
  String get deliveryRequestSavedNote => _ar
      ? 'تم حفظ الطلب — فيك تفتح سجل التوصيل بأي وقت.'
      : 'Request saved — you can open Delivery history anytime.';
  String get signInToSaveDeliveryOnServer => _ar
      ? 'سجّل دخول بحساب حقيقي لحفظ التوصيل على السيرفر.'
      : 'Sign in with a real account to save this delivery on the server.';
  String get deliveryAddressesRequired => _ar
      ? 'عناوين الاستلام والتسليم مطلوبة.'
      : 'Pickup and drop-off addresses are required.';

  // —— Add balance ——
  String get addBalanceTitle => _ar ? 'إضافة رصيد' : 'Add Balance';
  String get currentBalance => _ar ? 'الرصيد الحالي' : 'Current Balance';
  String get chooseAmount => _ar ? 'اختر المبلغ' : 'Choose Amount';
  String get orCustomAmount =>
      _ar ? 'أو أدخل مبلغاً مخصصاً' : 'Or Enter Custom Amount';
  String get enterAmountHint => _ar ? 'أدخل المبلغ' : 'Enter amount';
  String get selectPaymentMethod =>
      _ar ? 'اختر طريقة الدفع' : 'Select Payment Method';
  String get noSavedCardsTopUpNote => _ar
      ? 'لا بطاقات محفوظة. فيك تكمل الشحن؛ المصدر يظهر كمحفظة على الإيصال.'
      : 'No saved cards. You can still top up; payment source will show as Wallet on the receipt.';
  String get addNewPaymentMethodLong => _ar
      ? 'إضافة طريقة دفع جديدة'
      : 'Add New Payment Method';
  String get summaryTopUpAmount => _ar ? 'مبلغ الشحن' : 'Top-up amount';
  String get summaryNewBalance => _ar ? 'الرصيد الجديد' : 'New balance';
  String get confirmTopUp => _ar ? 'تأكيد الشحن' : 'Confirm Top-up';
  String get backToWallet => _ar ? 'رجوع للمحفظة' : 'Back to Wallet';
  String get selectPaymentMethodSnack =>
      _ar ? 'اختر طريقة الدفع' : 'Select a payment method';
  String get signInToAddPaymentMethod => _ar
      ? 'سجّل الدخول لإضافة طريقة دفع'
      : 'Sign in to add a payment method';
  String expiresLine(String expiry) =>
      _ar ? 'ينتهي $expiry' : 'Expires $expiry';

  // —— Balance added ——
  String get balanceAddedSuccess =>
      _ar ? 'تمت إضافة الرصيد!' : 'Balance Added Successfully!';
  String walletToppedUpMessage(String amountFormatted) => _ar
      ? 'تم شحن محفظتك بمبلغ $amountFormatted.'
      : 'Your wallet has been topped up with $amountFormatted.';
  String get newBalanceLabel => _ar ? 'الرصيد الجديد' : 'New Balance';
  String get transactionIdLabel => _ar ? 'رقم العملية' : 'Transaction ID';
  String get paymentMethodLabel => _ar ? 'طريقة الدفع' : 'Payment Method';
  String get dateTimeLabel => _ar ? 'التاريخ والوقت' : 'Date & Time';
  String get viewReceipt => _ar ? 'عرض الإيصال' : 'View Receipt';

  // —— Payment methods list ——
  String get paymentMethodsScreenTitle =>
      _ar ? 'طرق الدفع' : 'Payment Methods';
  String get defaultPaymentInfo => _ar
      ? 'طريقة الدفع الافتراضية تُخصم تلقائياً بنهاية كل رحلة.'
      : 'Your default payment method will be charged automatically at the end of each trip.';
  String get noSavedCardsYet => _ar
      ? 'لا بطاقات محفوظة بعد. أضف واحدة لاحقاً.'
      : 'No saved cards yet. Add one below when available.';
  String get rideGoWalletTitle => _ar ? 'محفظة RideGo' : 'RideGo Wallet';
  String walletBalanceLine(String formatted) =>
      _ar ? 'الرصيد: $formatted' : 'Balance: $formatted';
  String get cashTitle => _ar ? 'نقداً' : 'Cash';
  String get payDriverInCash =>
      _ar ? 'الدفع للسائق نقداً' : 'Pay driver in cash';
  String get alwaysAvailable => _ar ? 'متاح دائماً' : 'Always available';
  String get defaultBadge => _ar ? 'افتراضي' : 'Default';

  // —— Add card ——
  String get addCardTitle => _ar ? 'إضافة بطاقة' : 'Add card';
  String get cardTypeLabel => _ar ? 'نوع البطاقة' : 'Card type';
  String get lastFourDigitsLabel => _ar ? 'آخر 4 أرقام' : 'Last 4 digits';
  String get expiryLabel => _ar ? 'انتهاء الصلاحية' : 'Expiry';
  String get cardDisclaimer => _ar
      ? 'يُخزَّن آخر الأرقام والتاريخ فقط (وضع تجريبي). لا تدخل رقم البطاقة كاملاً في التطبيق.'
      : 'Only last digits and expiry are stored (demo-style). Never enter a full card number in the app.';
  String get saveCard => _ar ? 'حفظ البطاقة' : 'Save card';
  String get cardSavedSnack => _ar ? 'تم حفظ البطاقة' : 'Card saved';
  String get enterExactlyFourDigits =>
      _ar ? 'أدخل 4 أرقام بالضبط' : 'Enter exactly 4 digits';

  // —— Driver info / delivery map ——
  String get driverInfoAppBar => _ar ? 'معلومات السائق' : 'Driver info';
  String get driverOnTheWay => _ar ? 'السائق بالطريق' : 'Driver is on the way';
  String get simulateDriverArrived =>
      _ar ? 'محاكاة: وصول السائق' : 'Simulate: Driver Arrived';
  String get callDriver => _ar ? 'اتصال' : 'Call';
  String get chatDriver => _ar ? 'محادثة' : 'Chat';
  String get shareTrip => _ar ? 'مشاركة' : 'Share';
  String get emergency => _ar ? 'طوارئ' : 'Emergency';
  String minAwayLabel(int min) => _ar ? '~$min د' : '$min min away';

  String get deliveryFoundAppBar =>
      _ar ? 'تم إيجاد التوصيل' : 'Delivery found';

  // —— Trip details ——
  String get tripDetailsTitle => _ar ? 'تفاصيل الرحلة' : 'Trip Details';
  String get deliveryDetailsTitle =>
      _ar ? 'تفاصيل التوصيل' : 'Delivery Details';
  String get sectionPackage => _ar ? 'الطرد' : 'Package';
  String get sectionDriver => _ar ? 'السائق' : 'Driver';
  String get sectionDriverCourier =>
      _ar ? 'السائق / المندوب' : 'Driver / courier';
  String get deliveryFeeSection => _ar ? 'أجرة التوصيل' : 'Delivery fee';
  String get fareBreakdownSection =>
      _ar ? 'تفاصيل الأجرة' : 'Fare Breakdown';
  String get baseFareLabel => _ar ? 'أجرة أساسية' : 'Base fare';
  String distanceKmLabel(double km) => _ar
      ? 'المسافة (${km.toStringAsFixed(1)} كم)'
      : 'Distance (${km.toStringAsFixed(1)} km)';
  String timeMinLabel(int min) =>
      _ar ? 'الوقت ($min دقيقة)' : 'Time ($min min)';
  String get fareTotalLabel => _ar ? 'المجموع' : 'Total';
  String get paymentMethodSection =>
      _ar ? 'طريقة الدفع' : 'Payment method';
  String get downloadReceipt =>
      _ar ? 'تنزيل الإيصال' : 'Download Receipt';
  String get pickupCaption => _ar ? 'الاستلام' : 'Pickup';
  String get dropoffCaption => _ar ? 'التسليم' : 'Drop-off';

  // —— Notifications inbox ——
  String get notificationsTitle => _ar ? 'الإشعارات' : 'Notifications';
  String get readAllNotifications => _ar ? 'قراءة الكل' : 'Read all';
  String get notificationSettingsTooltip =>
      _ar ? 'إعدادات الإشعارات' : 'Notification settings';
  String get signInForNotifications => _ar
      ? 'سجّل الدخول لعرض إشعاراتك.'
      : 'Sign in to see your notifications.';
  String get allMarkedReadSnack =>
      _ar ? 'تم تعليم الكل كمقروء' : 'All marked as read';
  String get noNotifications => _ar ? 'لا إشعارات' : 'No notifications';

  /// Display label for filter chip; keep API value as [key] (`All`, `Jobs`, …).
  String inboxCategoryLabel(String key) {
    switch (key) {
      case 'All':
        return _ar ? 'الكل' : 'All';
      case 'Jobs':
        return _ar ? 'مهام' : 'Jobs';
      case 'Earnings':
        return _ar ? 'الأرباح' : 'Earnings';
      case 'System':
        return _ar ? 'النظام' : 'System';
      default:
        return key;
    }
  }

  // —— Notification settings ——
  String get notifSettingsTitle =>
      _ar ? 'إعدادات الإشعارات' : 'Notification settings';
  String get notifSectionRide => _ar ? 'تحديثات الرحلة' : 'Ride Updates';
  String get notifDriverAssigned => _ar ? 'تعيين سائق' : 'Driver Assigned';
  String get notifDriverAssignedSub =>
      _ar ? 'عند قبول السائق لرحلتك' : 'When driver accepts your ride';
  String get notifDriverArrived => _ar ? 'وصول السائق' : 'Driver Arrived';
  String get notifDriverArrivedSub =>
      _ar ? 'عند وصول السائق لنقطة الاستلام' : 'When driver reaches pickup';
  String get notifTripStarted => _ar ? 'بدء الرحلة' : 'Trip Started';
  String get notifTripStartedSub =>
      _ar ? 'عند بدء الرحلة' : 'When trip begins';
  String get notifSectionDelivery =>
      _ar ? 'تحديثات التوصيل' : 'Delivery Updates';
  String get notifPackagePickedUp =>
      _ar ? 'استلام الطرد' : 'Package Picked Up';
  String get notifPackagePickedUpSub =>
      _ar ? 'عند استلام السائق للطرد' : 'When driver collects package';
  String get notifOutForDelivery =>
      _ar ? 'قيد التوصيل' : 'Out for Delivery';
  String get notifOutForDeliverySub =>
      _ar ? 'أثناء التوجه للوجهة' : 'When heading to destination';
  String get notifDelivered => _ar ? 'تم التسليم' : 'Delivered';
  String get notifDeliveredSub =>
      _ar ? 'عند تسليم الطرد' : 'When package is delivered';
  String get notifSectionGeneral => _ar ? 'عام' : 'General';
  String get notifPromotions => _ar ? 'عروض وتخفيضات' : 'Promotions & Offers';
  String get notifPromotionsSub =>
      _ar ? 'عروض خاصة' : 'Special deals and discounts';
  String get notifSystem => _ar ? 'إشعارات النظام' : 'System Notifications';
  String get notifSystemSub =>
      _ar ? 'تحديثات وإعلانات' : 'Updates and announcements';
  String get notifSound => _ar ? 'الصوت' : 'Sound';
  String get notifSoundSub =>
      _ar ? 'تشغيل أصوات للإشعارات' : 'Play sounds for notifications';

  // —— Privacy & safety ——
  String get privacySafetyTitle =>
      _ar ? 'الخصوصية والأمان' : 'Privacy & Safety';
  String get privacySectionSharing =>
      _ar ? 'مشاركة الرحلة' : 'Trip Sharing';
  String get privacyShareTripTitle =>
      _ar ? 'مشاركة حالة الرحلة' : 'Share Trip Status';
  String get privacyShareTripSub =>
      _ar ? 'ليتابع أصدقاؤك رحلتك' : 'Let contacts track your ride';
  String get privacyEmergencyAlerts =>
      _ar ? 'تنبيهات الطوارئ' : 'Emergency Alerts';
  String get privacyEmergencyAlertsSub =>
      _ar ? 'إرسال SOS لجهات الطوارئ' : 'Send SOS to emergency contacts';
  String get privacySectionSettings =>
      _ar ? 'إعدادات الخصوصية' : 'Privacy Settings';
  String get privacyHidePhone => _ar ? 'إخفاء رقم هاتفي' : 'Hide My Phone Number';
  String get privacyHidePhoneSub =>
      _ar ? 'عن السائقين بعد الرحلة' : 'From drivers after trip';
  String get privacyShowPhoto =>
      _ar ? 'إظهار صورة الملف' : 'Show Profile Picture';
  String get privacyShowPhotoSub =>
      _ar ? 'ظاهرة للسائقين' : 'Visible to drivers';
  String get privacyDataCollection =>
      _ar ? 'جمع البيانات' : 'Data Collection';
  String get privacyDataCollectionSub =>
      _ar ? 'أقل قدر ممكن من البيانات' : 'Minimal data only';
  String get privacyInfoBanner => _ar
      ? 'خصوصيتك وأمانك أولويتنا. تتحكم بمن يرى معلوماتك ومتى.'
      : 'Your privacy and safety are our top priority. You can control who sees your information and when.';
  String get privacySectionEmergencyContacts =>
      _ar ? 'جهات اتصال للطوارئ' : 'Emergency Contacts';
  String get privacyEmergencyContactsHint => _ar
      ? 'أضف جهات موثوقة للإشعار عند الطوارئ.'
      : 'Add trusted contacts to notify in case of emergency.';
  String get privacyAddEmergencyContact =>
      _ar ? 'إضافة جهة طوارئ' : 'Add Emergency Contact';
  String get privacyEmergencyNameLabel =>
      _ar ? 'الاسم' : 'Name';
  String get privacyEmergencyPhoneLabel =>
      _ar ? 'رقم الهاتف' : 'Phone number';
  String get privacyEmergencyRelationshipLabel =>
      _ar ? 'صلة القرابة (اختياري)' : 'Relationship (optional)';
  String get privacyEmergencySave =>
      _ar ? 'حفظ' : 'Save';
  String get privacyEmergencyCancel =>
      _ar ? 'إلغاء' : 'Cancel';
  String get privacyEmergencyNameRequired =>
      _ar ? 'أدخل الاسم' : 'Enter a name';
  String get privacyEmergencyPhoneRequired =>
      _ar ? 'أدخل رقم الهاتف' : 'Enter a phone number';
  String get privacyNeedAccountForContacts => _ar
      ? 'سجّل الدخول بحساب على السيرفر لحفظ جهات الطوارئ.'
      : 'Sign in with a server account to save emergency contacts.';
  String get privacyContactSaved =>
      _ar ? 'تم حفظ جهة الطوارئ' : 'Emergency contact saved';
  String get privacyContactRemoved =>
      _ar ? 'تم الحذف' : 'Removed';

  // —— Edit personal info ——
  String get editPersonalInfoTitle =>
      _ar ? 'تعديل المعلومات الشخصية' : 'Edit Personal Info';
  String get profileFullName => _ar ? 'الاسم الكامل' : 'Full Name';
  String get profileFullNameHint =>
      _ar ? 'أدخل اسمك الكامل' : 'Enter your full name';
  String get profileEmail => _ar ? 'البريد الإلكتروني' : 'Email';
  String get profileEmailHint =>
      _ar ? 'أدخل بريدك' : 'Enter your email';
  String get profilePhone => _ar ? 'رقم الهاتف' : 'Phone Number';
  String get profilePhoneHint =>
      _ar ? 'أدخل رقم هاتفك' : 'Enter your phone';
  String get profilePhoneLockedHint => _ar
      ? 'تواصل مع الدعم لتغيير رقم الهاتف.'
      : 'Contact support to change your phone number.';
  String get profileDataInfo => _ar
      ? 'تُستخدم معلومات ملفك للتحقق من الحساب والتواصل.'
      : 'Your profile information is used for account verification and communication purposes.';
  String get profilePleaseEnterName =>
      _ar ? 'يرجى إدخال الاسم الكامل' : 'Please enter your full name';
  String get profileSaveChanges =>
      _ar ? 'حفظ التغييرات' : 'Save Changes';
  String get profileChangePhoto =>
      _ar ? 'تغيير الصورة' : 'Change Photo';
  String get profileTakePhoto =>
      _ar ? 'التقاط صورة' : 'Take Photo';
  String get profileChooseGallery =>
      _ar ? 'اختيار من المعرض' : 'Choose from Gallery';
  String profileCouldNotSavePhoto(Object e) => _ar
      ? 'تعذر حفظ الصورة: $e'
      : 'Could not save photo: $e';
  String profileCouldNotPickImage(Object e) => _ar
      ? 'تعذر اختيار الصورة: $e'
      : 'Could not pick image: $e';

  // —— Wallet receipt ——
  String get receiptTitle => _ar ? 'إيصال' : 'Receipt';
  String get receiptWalletTopUp =>
      _ar ? 'شحن المحفظة' : 'Wallet top-up';
  String get receiptAmount => _ar ? 'المبلغ' : 'Amount';
  String get receiptNewBalanceRow =>
      _ar ? 'الرصيد الجديد' : 'New balance';
  String get receiptPaymentMethodRow =>
      _ar ? 'طريقة الدفع' : 'Payment method';
  String get receiptDateTimeRow =>
      _ar ? 'التاريخ والوقت' : 'Date & time';
  String get receiptThankYou => _ar
      ? 'شكراً لاستخدامك وصّل.'
      : 'Thank you for using Waseel.';

  // —— Trip in-progress (start / complete) ——
  String get tripTitleComplete =>
      _ar ? 'إكمال الرحلة' : 'COMPLETE TRIP';
  String get tripTitleStart => _ar ? 'بدء الرحلة' : 'START TRIP';
  String get mapStatusEnjoyRide =>
      _ar ? 'تمتع برحلتك' : 'Enjoy your ride';
  String get mapStatusDriverArrived =>
      _ar ? 'وصل السائق' : 'Driver has arrived';
  String get tripCompleteButton =>
      _ar ? 'إكمال الرحلة' : 'Complete Trip';
  String get tripSimulateStart =>
      _ar ? 'محاكاة: بدء الرحلة' : 'Simulate: Start Trip';

  // —— Rating ——
  String get ratingTitleRateTrip =>
      _ar ? 'تقييم الرحلة' : 'RATE TRIP';
  String get ratingTitleRating =>
      _ar ? 'التقييم' : 'RATING';
  String get ratingHowWasTrip =>
      _ar ? 'كيف كانت رحلتك؟' : 'How was your trip?';
  String ratingSubtitleRide(String name) => _ar
      ? 'قيّم تجربتك مع $name'
      : 'Rate your experience with $name';
  String ratingSubtitleDelivery(String name) => _ar
      ? 'قيّم تجربة التوصيل مع $name'
      : 'Rate your delivery experience with $name';
  String get ratingTapStars =>
      _ar ? 'اضغط لاختيار النجوم' : 'Tap to select stars';
  String ratingStarsOfFive(int n) =>
      _ar ? '$n من 5 نجوم' : '$n of 5 stars';
  String get ratingSubmit =>
      _ar ? 'إرسال التقييم' : 'Submit Rating';
  String get ratingSkip => _ar ? 'تخطي' : 'Skip';

  // —— Comment / feedback ——
  String get commentTitleDelivery =>
      _ar ? 'إضافة ملاحظات' : 'ADD FEEDBACK';
  String get commentTitleRide =>
      _ar ? 'تعليق للسائق' : 'COMMENT FOR DRIVER';
  String get commentHowWasDelivery =>
      _ar ? 'كيف كان التوصيل؟' : 'How was your delivery?';
  String commentTapChangeRating(String name) => _ar
      ? 'اضغط لتغيير تقييمك لـ $name'
      : 'Tap to change your rating for $name';
  String get commentAdditionalFeedback =>
      _ar ? 'ملاحظات إضافية (اختياري)' : 'Additional Feedback (Optional)';
  String get commentFeedbackHint => _ar
      ? 'أخبرنا المزيد عن تجربتك...'
      : 'Tell us more about your experience...';
  String get commentWhatLiked =>
      _ar ? 'ما الذي أعجبك؟' : 'What did you like?';

  /// Stable values sent to the rating API (`feedbackTags`).
  static String feedbackTagApiValue(String key) {
    switch (key) {
      case 'friendly_driver':
        return 'Friendly driver';
      case 'clean_car':
        return 'Clean car';
      case 'safe_driving':
        return 'Safe driving';
      case 'on_time':
        return 'On time';
      case 'good_music':
        return 'Good music';
      default:
        return key;
    }
  }

  String feedbackTagLabel(String key) {
    switch (key) {
      case 'friendly_driver':
        return _ar ? 'سائق ودود' : 'Friendly driver';
      case 'clean_car':
        return _ar ? 'سيارة نظيفة' : 'Clean car';
      case 'safe_driving':
        return _ar ? 'قيادة آمنة' : 'Safe driving';
      case 'on_time':
        return _ar ? 'في الوقت' : 'On time';
      case 'good_music':
        return _ar ? 'موسيقى جيدة' : 'Good music';
      default:
        return key;
    }
  }

  // —— Saved places ——
  String get savedPlacesTitle =>
      _ar ? 'الأماكن المحفوظة' : 'Saved Places';
  String get savedPlacesEmpty =>
      _ar ? 'لا توجد أماكن محفوظة.' : 'No saved places yet.';
  String get savedPlacesAddDialogTitle =>
      _ar ? 'إضافة مكان' : 'Add place';
  String get savedPlacesEditDialogTitle =>
      _ar ? 'تعديل المكان' : 'Edit place';
  String get savedPlacesFieldType => _ar ? 'النوع' : 'Type';
  String get savedPlacesFieldName => _ar ? 'الاسم' : 'Name';
  String get savedPlacesFieldAddress => _ar ? 'العنوان' : 'Address';
  String get buttonCancel => _ar ? 'إلغاء' : 'Cancel';
  String get buttonSave => _ar ? 'حفظ' : 'Save';
  String get savedPlacesAddNew =>
      _ar ? '+ إضافة مكان جديد' : '+ Add New Place';
  String get savedPlacesQuickTips =>
      _ar ? 'نصائح سريعة' : 'Quick Tips';
  String get savedPlacesTipServer => _ar
      ? 'تُحمّل الأماكن المحفوظة من السيرفر عند تسجيل الدخول بالبريد.'
      : 'Saved places load from the server when you log in with email.';
  String get savedPlacesTipTypes => _ar
      ? 'استخدم المنزل أو العمل أو النادي أو اسماً مخصصاً.'
      : 'Use Home / Work / Gym or a custom name.';
  String get savedPlacesTipPull => _ar
      ? 'اسحب للأسفل لتحديث القائمة.'
      : 'Pull down to refresh the list.';
  String get savedPlacesSheetEdit => _ar ? 'تعديل' : 'Edit';
  String get savedPlacesSheetDelete => _ar ? 'حذف' : 'Delete';

  String savedPlaceTypeLabel(SavedPlaceType type) {
    switch (type) {
      case SavedPlaceType.home:
        return _ar ? 'المنزل' : 'Home';
      case SavedPlaceType.work:
        return _ar ? 'العمل' : 'Work';
      case SavedPlaceType.gym:
        return _ar ? 'النادي' : 'Gym';
      case SavedPlaceType.custom:
        return _ar ? 'مخصص' : 'Custom';
    }
  }

  // —— Locale-aware dates (no intl package) ——
  static const _enMonthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String _monthShort(int month) =>
      _ar ? _arMonths[month - 1] : _enMonthsShort[month - 1];

  /// e.g. `15 Jan 2026` / `15 يناير 2026`
  String formatDateDayMonthYear(DateTime d) =>
      '${d.day} ${_monthShort(d.month)} ${d.year}';

  /// e.g. `15 Jan` / `15 يناير`
  String formatDateDayMonth(DateTime d) =>
      '${d.day} ${_monthShort(d.month)}';

  /// Trip details: `15 Jan 2026 • 14:05`
  String formatDateTimeDetailLine(DateTime dt) {
    final t =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.day} ${_monthShort(dt.month)} ${dt.year} • $t';
  }

  /// Top-up receipt line (12h + AM/PM or ص/م).
  String formatTopUpReceiptDateTime(DateTime d) {
    final h12 = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final min = d.minute.toString().padLeft(2, '0');
    final timeStr = '$h12:$min';
    if (_ar) {
      final suffix = d.hour >= 12 ? 'م' : 'ص';
      return '${d.day} ${_monthShort(d.month)} ${d.year} · $timeStr $suffix';
    }
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${_monthShort(d.month)} ${d.day}, ${d.year} · $timeStr $period';
  }

  /// `Jan 2, 2026` / `2 يناير 2026` (for driver payout details, transaction lines).
  String formatDateMonthCommaDayYear(DateTime d) => _ar
      ? '${d.day} ${_monthShort(d.month)} ${d.year}'
      : '${_monthShort(d.month)} ${d.day}, ${d.year}';

  /// 12-hour time with AM/PM or ص/م.
  String formatTime12hAmPm(DateTime d) {
    final h12 = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final min = d.minute.toString().padLeft(2, '0');
    if (_ar) {
      return '$h12:$min ${d.hour >= 12 ? 'م' : 'ص'}';
    }
    return '$h12:$min ${d.hour >= 12 ? 'PM' : 'AM'}';
  }

  /// Balance-added success line (comma before time).
  String formatBalanceAddedDateTime(DateTime d) {
    final h12 = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final min = d.minute.toString().padLeft(2, '0');
    final timeStr = '$h12:$min';
    if (_ar) {
      final suffix = d.hour >= 12 ? 'م' : 'ص';
      return '${d.day} ${_monthShort(d.month)} ${d.year}، $timeStr $suffix';
    }
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${_monthShort(d.month)} ${d.day}, ${d.year}, $timeStr $period';
  }
}
