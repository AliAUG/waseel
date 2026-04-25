import 'package:flutter/foundation.dart';

class DriverSettingsProvider extends ChangeNotifier {
  bool _jobAlerts = true;
  bool _promotions = true;
  bool _systemMessages = false;
  bool _sound = true;

  bool get jobAlerts => _jobAlerts;
  bool get promotions => _promotions;
  bool get systemMessages => _systemMessages;
  bool get sound => _sound;

  void setJobAlerts(bool value) {
    _jobAlerts = value;
    notifyListeners();
  }

  void setPromotions(bool value) {
    _promotions = value;
    notifyListeners();
  }

  void setSystemMessages(bool value) {
    _systemMessages = value;
    notifyListeners();
  }

  void setSound(bool value) {
    _sound = value;
    notifyListeners();
  }
}
