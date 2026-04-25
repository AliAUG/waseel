import 'package:waseel/core/network/api_client.dart';
import 'package:waseel/core/network/backend_endpoints.dart';

class AuthApiService {
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> registerEmail({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  }) {
    return _client.post(
      BackendEndpoints.registerEmail,
      body: <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber,
      },
    );
  }

  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String email,
    required String code,
  }) {
    return _client.post(
      BackendEndpoints.verifyRegistrationEmail,
      body: <String, dynamic>{'email': email, 'code': code},
    );
  }

  Future<Map<String, dynamic>> sendOtpByEmail({
    required String email,
    required String type,
  }) {
    return _client.post(
      BackendEndpoints.sendOtpEmail,
      body: <String, dynamic>{'email': email, 'type': type},
    );
  }

  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _client.post(
      BackendEndpoints.loginEmail,
      body: <String, dynamic>{'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> requestEmailOtp({
    required String email,
  }) {
    return _client.post(
      BackendEndpoints.loginEmailOtp,
      body: <String, dynamic>{'email': email},
    );
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String code,
  }) {
    return _client.post(
      BackendEndpoints.verifyLoginEmailOtp,
      body: <String, dynamic>{'email': email, 'code': code},
    );
  }

  Future<Map<String, dynamic>> getProfile(String token) {
    return _client.get(
      BackendEndpoints.profile,
      token: token,
    );
  }

  /// `POST /auth/reset-password/email` — sends OTP (`type` password_reset on server).
  Future<Map<String, dynamic>> requestPasswordReset({required String email}) {
    return _client.post(
      BackendEndpoints.resetPasswordEmail,
      body: <String, dynamic>{'email': email},
    );
  }

  /// `POST /auth/reset-password/email/verify` — returns new `token` + `user`.
  Future<Map<String, dynamic>> verifyPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _client.post(
      BackendEndpoints.resetPasswordEmailVerify,
      body: <String, dynamic>{
        'email': email,
        'code': code,
        'newPassword': newPassword,
      },
    );
  }
}
