import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local notification toggles — persisted on device only (no backend).
class NotificationSettingsProvider extends ChangeNotifier {
  NotificationSettingsProvider() {
    _restore();
  }

  static const _prefix = 'notif_settings_';
  static const _kDriverAssigned = '${_prefix}driver_assigned';
  static const _kDriverArrived = '${_prefix}driver_arrived';
  static const _kTripStarted = '${_prefix}trip_started';
  static const _kPackagePickedUp = '${_prefix}package_picked_up';
  static const _kOutForDelivery = '${_prefix}out_for_delivery';
  static const _kDelivered = '${_prefix}delivered';
  static const _kPromotionsOffers = '${_prefix}promotions_offers';
  static const _kSystemNotifications = '${_prefix}system_notifications';
  static const _kSound = '${_prefix}sound';

  bool _driverAssigned = true;
  bool _driverArrived = true;
  bool _tripStarted = true;
  bool _packagePickedUp = true;
  bool _outForDelivery = true;
  bool _delivered = true;
  bool _promotionsOffers = true;
  bool _systemNotifications = false;
  bool _sound = true;

  bool get driverAssigned => _driverAssigned;
  bool get driverArrived => _driverArrived;
  bool get tripStarted => _tripStarted;
  bool get packagePickedUp => _packagePickedUp;
  bool get outForDelivery => _outForDelivery;
  bool get delivered => _delivered;
  bool get promotionsOffers => _promotionsOffers;
  bool get systemNotifications => _systemNotifications;
  bool get sound => _sound;

  /// Applies `UserSettings.notifications` from `GET /users/settings`.
  void applyFromServerMap(Map<String, dynamic> m) {
    bool? read(String key) {
      final v = m[key];
      if (v is bool) return v;
      return null;
    }

    final da = read('driverAssigned');
    if (da != null) _driverAssigned = da;
    final dr = read('driverArrived');
    if (dr != null) _driverArrived = dr;
    final ts = read('tripStarted');
    if (ts != null) _tripStarted = ts;
    final pk = read('packagePickedUp');
    if (pk != null) _packagePickedUp = pk;
    final od = read('outForDelivery');
    if (od != null) _outForDelivery = od;
    final del = read('delivered');
    if (del != null) _delivered = del;
    final po = read('promotionsAndOffers');
    if (po != null) _promotionsOffers = po;
    final sys = read('systemNotifications');
    if (sys != null) _systemNotifications = sys;
    final snd = read('sound');
    if (snd != null) _sound = snd;

    notifyListeners();
    unawaited(_persist());
  }

  /// Full `notifications` object for `PUT /users/settings`.
  Map<String, dynamic> toServerNotificationsMap() => {
        'driverAssigned': _driverAssigned,
        'driverArrived': _driverArrived,
        'tripStarted': _tripStarted,
        'packagePickedUp': _packagePickedUp,
        'outForDelivery': _outForDelivery,
        'delivered': _delivered,
        'promotionsAndOffers': _promotionsOffers,
        'systemNotifications': _systemNotifications,
        'sound': _sound,
      };

  Future<void> _restore() async {
    try {
      final p = await SharedPreferences.getInstance();
      _driverAssigned = p.getBool(_kDriverAssigned) ?? true;
      _driverArrived = p.getBool(_kDriverArrived) ?? true;
      _tripStarted = p.getBool(_kTripStarted) ?? true;
      _packagePickedUp = p.getBool(_kPackagePickedUp) ?? true;
      _outForDelivery = p.getBool(_kOutForDelivery) ?? true;
      _delivered = p.getBool(_kDelivered) ?? true;
      _promotionsOffers = p.getBool(_kPromotionsOffers) ?? true;
      _systemNotifications = p.getBool(_kSystemNotifications) ?? false;
      _sound = p.getBool(_kSound) ?? true;
    } catch (_) {
      /* keep defaults */
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await Future.wait([
        p.setBool(_kDriverAssigned, _driverAssigned),
        p.setBool(_kDriverArrived, _driverArrived),
        p.setBool(_kTripStarted, _tripStarted),
        p.setBool(_kPackagePickedUp, _packagePickedUp),
        p.setBool(_kOutForDelivery, _outForDelivery),
        p.setBool(_kDelivered, _delivered),
        p.setBool(_kPromotionsOffers, _promotionsOffers),
        p.setBool(_kSystemNotifications, _systemNotifications),
        p.setBool(_kSound, _sound),
      ]);
    } catch (_) {
      /* ignore disk errors */
    }
  }

  void setDriverAssigned(bool v) {
    _driverAssigned = v;
    notifyListeners();
    _persist();
  }

  void setDriverArrived(bool v) {
    _driverArrived = v;
    notifyListeners();
    _persist();
  }

  void setTripStarted(bool v) {
    _tripStarted = v;
    notifyListeners();
    _persist();
  }

  void setPackagePickedUp(bool v) {
    _packagePickedUp = v;
    notifyListeners();
    _persist();
  }

  void setOutForDelivery(bool v) {
    _outForDelivery = v;
    notifyListeners();
    _persist();
  }

  void setDelivered(bool v) {
    _delivered = v;
    notifyListeners();
    _persist();
  }

  void setPromotionsOffers(bool v) {
    _promotionsOffers = v;
    notifyListeners();
    _persist();
  }

  void setSystemNotifications(bool v) {
    _systemNotifications = v;
    notifyListeners();
    _persist();
  }

  void setSound(bool v) {
    _sound = v;
    notifyListeners();
    _persist();
  }
}
