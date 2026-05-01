class BackendEndpoints {
  const BackendEndpoints._();

  static const String health = '/health';

  static const String registerEmail = '/auth/register/email';
  static const String sendOtpEmail = '/auth/send-otp/email';
  static const String verifyRegistrationEmail =
      '/auth/verify-registration/email';
  static const String loginEmail = '/auth/login/email';
  static const String loginEmailOtp = '/auth/login/email/otp';
  static const String verifyLoginEmailOtp = '/auth/login/email/otp/verify';
  static const String resetPasswordEmail = '/auth/reset-password/email';
  static const String resetPasswordEmailVerify =
      '/auth/reset-password/email/verify';
  static const String profile = '/auth/profile';

  static const String rideTypes = '/trips/ride-types';
  static const String trips = '/trips';

  static String tripDetails(String tripId) => '/trips/$tripId/details';
  static String tripRate(String tripId) => '/trips/$tripId/rate';

  static const String deliveries = '/deliveries';
  static const String deliveryComplete = '/deliveries/complete';
  static String deliveryRate(String id) => '/deliveries/$id/rate';

  static const String history = '/history';
  static String historyDeliveryDetails(String id) => '/history/deliveries/$id';

  static const String settings = '/users/settings';
  static const String userProfile = '/users/profile';
  static const String savedPlaces = '/users/saved-places';
  static String savedPlaceById(String id) => '/users/saved-places/$id';

  static const String wallet = '/wallet';
  static const String walletAddBalance = '/wallet/add-balance';
  static const String walletPaymentMethods = '/wallet/payment-methods';
  static String walletPaymentMethodSetDefault(String id) =>
      '/wallet/payment-methods/$id/default';
  static const String walletTransactions = '/wallet/transactions';

  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationMarkRead(String id) => '/notifications/$id/read';

  // Driver
  static const String driverDashboard = '/driver/dashboard';
  static const String driverRequests = '/driver/ride-requests';

  static String driverRideRequestAccept(String id) =>
      '/driver/ride-requests/$id/accept';

  static String driverRideRequestDecline(String id) =>
      '/driver/ride-requests/$id/decline';

  static const String driverTrips = '/driver/trips';

  static String driverTripById(String tripId) => '/driver/trips/$tripId';

  static String driverTripStatus(String tripId) =>
      '/driver/trips/$tripId/status';

  static const String driverWallet = '/driver/wallet';
  static const String driverTransactions = '/driver/transactions';
  static const String driverPayout = '/driver/payout';
}
