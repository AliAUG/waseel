import 'package:flutter/foundation.dart';
import 'package:waseel/features/passenger/models/emergency_contact.dart';

class PrivacySafetyProvider extends ChangeNotifier {
  bool _shareTripStatus = true;
  bool _emergencyAlerts = true;
  bool _hideMyPhoneNumber = false;
  bool _showProfilePicture = true;
  bool _dataCollection = true;
  List<EmergencyContactEntry> _emergencyContacts = [];

  bool get shareTripStatus => _shareTripStatus;
  bool get emergencyAlerts => _emergencyAlerts;
  bool get hideMyPhoneNumber => _hideMyPhoneNumber;
  bool get showProfilePicture => _showProfilePicture;
  bool get dataCollection => _dataCollection;
  List<EmergencyContactEntry> get emergencyContacts =>
      List<EmergencyContactEntry>.unmodifiable(_emergencyContacts);

  /// Applies `UserSettings.privacy` from `GET /users/settings`.
  void applyFromServerMap(Map<String, dynamic> m) {
    bool? read(String key) {
      final v = m[key];
      if (v is bool) return v;
      return null;
    }

    final st = read('shareTripStatus');
    if (st != null) _shareTripStatus = st;
    final em = read('emergencyAlerts');
    if (em != null) _emergencyAlerts = em;
    final hp = read('hidePhoneNumber');
    if (hp != null) _hideMyPhoneNumber = hp;
    final sh = read('showProfilePicture');
    if (sh != null) _showProfilePicture = sh;
    final dc = read('dataCollection');
    if (dc != null) _dataCollection = dc;
    notifyListeners();
  }

  /// Top-level `emergencyContacts` from `GET /users/settings`.
  void applyEmergencyContactsFromServer(List<dynamic>? raw) {
    if (raw == null) return;
    _emergencyContacts = raw
        .whereType<Map>()
        .map((e) => EmergencyContactEntry.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .where((c) => c.name.trim().isNotEmpty && c.phoneNumber.trim().isNotEmpty)
        .toList();
    notifyListeners();
  }

  void setEmergencyContacts(List<EmergencyContactEntry> value) {
    _emergencyContacts = List<EmergencyContactEntry>.from(value);
    notifyListeners();
  }

  void addEmergencyContact(EmergencyContactEntry c) {
    _emergencyContacts = [..._emergencyContacts, c];
    notifyListeners();
  }

  void removeEmergencyContactAt(int index) {
    if (index < 0 || index >= _emergencyContacts.length) return;
    _emergencyContacts = List<EmergencyContactEntry>.from(_emergencyContacts)
      ..removeAt(index);
    notifyListeners();
  }

  List<Map<String, dynamic>> emergencyContactsToServerList() =>
      _emergencyContacts.map((e) => e.toJson()).toList();

  /// Full `privacy` object for `PUT /users/settings`.
  Map<String, dynamic> toServerPrivacyMap() => {
        'shareTripStatus': _shareTripStatus,
        'emergencyAlerts': _emergencyAlerts,
        'hidePhoneNumber': _hideMyPhoneNumber,
        'showProfilePicture': _showProfilePicture,
        'dataCollection': _dataCollection,
      };

  void setShareTripStatus(bool v) {
    _shareTripStatus = v;
    notifyListeners();
  }

  void setEmergencyAlerts(bool v) {
    _emergencyAlerts = v;
    notifyListeners();
  }

  void setHideMyPhoneNumber(bool v) {
    _hideMyPhoneNumber = v;
    notifyListeners();
  }

  void setShowProfilePicture(bool v) {
    _showProfilePicture = v;
    notifyListeners();
  }

  void setDataCollection(bool v) {
    _dataCollection = v;
    notifyListeners();
  }
}
