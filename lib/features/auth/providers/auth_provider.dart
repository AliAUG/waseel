import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/features/auth/data/auth_api_service.dart';
import 'package:waseel/features/auth/models/user_model.dart';
import 'package:waseel/features/passenger/data/user_api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthApiService? authApiService,
    SharedPreferences? prefs,
  })  : _authApi = authApiService ?? AuthApiService(),
        _prefs = prefs;

  static const String _kTokenKey = 'waseel_auth_token';
  static const String _kUserKey = 'waseel_auth_user';

  final AuthApiService _authApi;
  final SharedPreferences? _prefs;
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _lastError;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  bool get isLoggedIn => _user != null;

  /// Call once at startup (e.g. from [SessionGate]) to restore token + user from disk.
  Future<void> loadPersistedSession() async {
    final p = _prefs;
    if (p == null) return;
    final token = p.getString(_kTokenKey);
    final raw = p.getString(_kUserKey);
    if (token == null ||
        token.isEmpty ||
        raw == null ||
        raw.isEmpty) {
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _token = token;
      _user = UserModel.fromJson(map);
      notifyListeners();
    } catch (_) {
      await p.remove(_kTokenKey);
      await p.remove(_kUserKey);
    }
  }

  void _saveSession() {
    final p = _prefs;
    if (p == null) return;
    final t = _token;
    final u = _user;
    if (t == null || t.isEmpty || u == null) {
      p.remove(_kTokenKey);
      p.remove(_kUserKey);
      return;
    }
    p.setString(_kTokenKey, t);
    p.setString(_kUserKey, jsonEncode(u.toJson()));
  }

  void setUserFromSignUp({
    required String name,
    required String phone,
    String? email,
    String? profileImagePath,
  }) {
    _user = UserModel(
      name: name,
      phone: phone,
      email: email?.trim().isEmpty == true ? null : email,
      profileImagePath: profileImagePath,
      role: null,
      tripsCount: 0,
      deliveriesCount: 0,
      rating: 0,
    );
    _token ??= 'local-session';
    _saveSession();
    notifyListeners();
  }

  void setUserFromLogin({
    required String phone,
    String? name,
    String? email,
    String? profileImagePath,
  }) {
    _user = UserModel(
      name: name ?? 'Passenger',
      phone: phone,
      email: email,
      profileImagePath: profileImagePath,
      role: null,
      tripsCount: 28,
      deliveriesCount: 12,
      rating: 4.9,
    );
    _token ??= 'local-session';
    _saveSession();
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? email,
    String? profileImagePath,
  }) {
    if (_user == null) return;
    _user = UserModel(
      name: name ?? _user!.name,
      phone: _user!.phone,
      email: email ?? _user!.email,
      profileImagePath: profileImagePath ?? _user!.profileImagePath,
      role: _user!.role,
      tripsCount: _user!.tripsCount,
      deliveriesCount: _user!.deliveriesCount,
      rating: _user!.rating,
    );
    _saveSession();
    notifyListeners();
  }

  /// Persists name/email via `PUT /users/profile`. On success refreshes [_user] from response.
  /// Returns `false` if no real token or request fails ([lastError] set on failure).
  Future<bool> saveProfileToBackend({
    required String fullName,
    String? email,
  }) async {
    final t = _token;
    if (t == null || t.isEmpty || t == 'local-session') {
      return false;
    }
    _lastError = null;
    try {
      final resp = await UserApiService().updateProfile(
        t,
        fullName: fullName,
        email: email,
      );
      final raw = resp['data'];
      if (raw is Map) {
        _user = _userFromBackend(Map<String, dynamic>.from(raw));
        _saveSession();
        notifyListeners();
        return true;
      }
      return false;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    }
  }

  void logout() {
    _user = null;
    _token = null;
    _lastError = null;
    final p = _prefs;
    if (p != null) {
      p.remove(_kTokenKey);
      p.remove(_kUserKey);
    }
    notifyListeners();
  }

  /// Loads current user from `GET /auth/profile` (Bearer token). Updates [_user] on success.
  Future<bool> refreshProfile() async {
    final t = _token;
    if (t == null || t.isEmpty || t == 'local-session') {
      return false;
    }
    _lastError = null;
    try {
      final resp = await _authApi.getProfile(t);
      final raw = resp['data'];
      if (raw is! Map<String, dynamic>) return false;
      _user = _userFromBackend(raw);
      _saveSession();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    }
  }

  /// Backend-ready: registers account and asks backend to send OTP.
  Future<bool> registerEmail({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _authApi.registerEmail(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        phoneNumber: phoneNumber,
      );
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Backend-ready: verifies registration OTP and stores token+user.
  Future<bool> verifyRegistrationOtp({
    required String email,
    required String code,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await _authApi.verifyRegistrationOtp(email: email, code: code);
      final data = (resp['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      _token = data['token']?.toString();
      _user = _userFromBackend(data['user'] as Map<String, dynamic>?);
      _saveSession();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Backend-ready: email/password login.
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await _authApi.loginWithEmail(email: email, password: password);
      final data = (resp['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      _token = data['token']?.toString();
      _user = _userFromBackend(data['user'] as Map<String, dynamic>?);
      _saveSession();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Backend-ready: OTP login request.
  Future<bool> requestLoginEmailOtp({required String email}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _authApi.requestEmailOtp(email: email);
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestRegistrationEmailOtp({required String email}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _authApi.sendOtpByEmail(email: email, type: 'account_creation');
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends password-reset OTP to [email] (`POST /auth/reset-password/email`).
  Future<bool> requestPasswordReset({required String email}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _authApi.requestPasswordReset(email: email);
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifies OTP and sets new password; updates session from response.
  Future<bool> verifyPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await _authApi.verifyPasswordReset(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      final data = (resp['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      _token = data['token']?.toString();
      _user = _userFromBackend(data['user'] as Map<String, dynamic>?);
      _saveSession();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Backend-ready: OTP login verify.
  Future<bool> verifyLoginEmailOtp({
    required String email,
    required String code,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await _authApi.verifyEmailOtp(email: email, code: code);
      final data = (resp['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      _token = data['token']?.toString();
      _user = _userFromBackend(data['user'] as Map<String, dynamic>?);
      _saveSession();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers current device push token for this signed-in user.
  Future<bool> registerPushToken({
    required String pushToken,
    required String platform,
  }) async {
    final t = _token;
    if (t == null || t.isEmpty || t == 'local-session') return false;
    try {
      await UserApiService().registerPushToken(
        t,
        pushToken: pushToken,
        platform: platform,
      );
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  /// Removes current device push token from this signed-in user.
  Future<bool> unregisterPushToken({
    required String pushToken,
  }) async {
    final t = _token;
    if (t == null || t.isEmpty || t == 'local-session') return false;
    try {
      await UserApiService().unregisterPushToken(
        t,
        pushToken: pushToken,
      );
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  UserModel? _userFromBackend(Map<String, dynamic>? user) {
    if (user == null) return _user;
    final fullName = user['fullName']?.toString();
    final phone = user['phoneNumber']?.toString() ?? '';
    final email = user['email']?.toString();
    final role = user['role']?.toString();
    final pic = user['profilePicture']?.toString().trim();
    final profileImagePath =
        (pic != null && pic.isNotEmpty) ? pic : null;
    return UserModel(
      name: (fullName == null || fullName.isEmpty) ? 'User' : fullName,
      phone: phone,
      email: email,
      profileImagePath: profileImagePath,
      role: role,
      tripsCount: _intFromJson(user['tripsCount']),
      deliveriesCount: _intFromJson(user['deliveriesCount']),
      rating: _doubleFromJson(user['rating']),
    );
  }

  static int _intFromJson(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _doubleFromJson(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
