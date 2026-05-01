import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/features/passenger/data/user_api_service.dart';

enum AppLanguage { english, arabic }

enum AppThemeMode { light, dark }

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    UserApiService? userApi,
    SharedPreferences? prefs,
  })  : _userApi = userApi ?? UserApiService(),
        _prefs = prefs {
    _loadFromPrefs();
  }

  final UserApiService _userApi;
  final SharedPreferences? _prefs;

  static const _kLanguage = 'passenger_settings_language';
  static const _kTheme = 'passenger_settings_theme';

  AppLanguage _language = AppLanguage.english;
  AppThemeMode _theme = AppThemeMode.light;

  AppLanguage get language => _language;
  AppThemeMode get theme => _theme;

  String get languageLabel {
    switch (_language) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.arabic:
        return 'العربية';
    }
  }

  String get themeLabel {
    switch (_theme) {
      case AppThemeMode.light:
        return _language == AppLanguage.arabic ? 'فاتح' : 'Light';
      case AppThemeMode.dark:
        return _language == AppLanguage.arabic ? 'داكن' : 'Dark';
    }
  }

  void _loadFromPrefs() {
    final p = _prefs;
    if (p == null) return;
    final lang = p.getString(_kLanguage);
    if (lang == 'ar') {
      _language = AppLanguage.arabic;
    } else if (lang == 'en') {
      _language = AppLanguage.english;
    }
    final th = p.getString(_kTheme);
    if (th == 'dark') {
      _theme = AppThemeMode.dark;
    } else if (th == 'light') {
      _theme = AppThemeMode.light;
    }
  }

  Future<void> _persistToPrefs() async {
    final p = _prefs;
    if (p == null) return;
    try {
      await p.setString(
        _kLanguage,
        _language == AppLanguage.arabic ? 'ar' : 'en',
      );
      await p.setString(
        _kTheme,
        _theme == AppThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {}
  }

  void setLanguage(AppLanguage lang) {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    unawaited(_persistToPrefs());
  }

  void setTheme(AppThemeMode mode) {
    if (_theme == mode) return;
    _theme = mode;
    notifyListeners();
    unawaited(_persistToPrefs());
  }

  /// Maps `GET /users/settings` document into [language] / [theme].
  void applyFromBackend(Map<String, dynamic> data) {
    final lang = data['language']?.toString().trim() ?? 'English';
    final lower = lang.toLowerCase();
    if (lower.contains('arabic') ||
        lower.contains('عربي') ||
        lang.contains('العربية')) {
      _language = AppLanguage.arabic;
    } else {
      _language = AppLanguage.english;
    }

    final th = data['theme']?.toString().trim().toLowerCase() ?? 'light';
    _theme = th == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
    notifyListeners();
    unawaited(_persistToPrefs());
  }

  /// Loads remote settings when [token] is a real JWT.
  Future<bool> loadFromServer(String? token) async {
    if (token == null || token.isEmpty || token == 'local-session') {
      return false;
    }
    try {
      final map = await _userApi.getSettings(token);
      if (map == null) return false;
      applyFromBackend(map);
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<bool> saveLanguageRegionToServer(String? token) async {
    if (token == null || token.isEmpty || token == 'local-session') {
      return false;
    }
    try {
      await _userApi.updateSettings(token, <String, dynamic>{
        'language': _language == AppLanguage.arabic ? 'Arabic' : 'English',
        'locale': _language == AppLanguage.arabic ? 'ar-LB' : 'en-LB',
        'region': 'Lebanon',
      });
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<bool> saveThemeToServer(String? token) async {
    if (token == null || token.isEmpty || token == 'local-session') {
      return false;
    }
    try {
      await _userApi.updateSettings(token, <String, dynamic>{
        'theme': _theme == AppThemeMode.dark ? 'dark' : 'light',
      });
      return true;
    } on ApiException {
      return false;
    }
  }
}
