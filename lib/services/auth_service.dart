import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_model.dart';

/// Authentication service — login, patient onboarding steps, token refresh.
class AuthService {
  AuthService._();

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  static Future<AuthResponse> login({
    required int contact,
    required String password,
  }) async {
    final response = await ApiConfig.post(
      '/users/login/',
      headers: ApiConfig.jsonHeaders,
      body: jsonEncode({'contact': contact, 'password': password}),
    );
    final data = ApiConfig.handleResponse(response) as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(data);
    await _persist(auth);
    return auth;
  }

  // ── PATIENT ONBOARDING ─────────────────────────────────────────────────────

  /// Step 1 — send OTP.
  static Future<int> step1({
    required int contact,
    required String name,
    required String password,
  }) async {
    final response = await ApiConfig.post(
      '/users/onboarding/patient/step1/',
      headers: ApiConfig.jsonHeaders,
      body: jsonEncode({
        'contact': contact,
        'name': name,
        'password': password,
      }),
    );
    final data = ApiConfig.handleResponse(response) as Map<String, dynamic>;
    return (data['contact'] is int)
        ? data['contact'] as int
        : int.parse(data['contact'].toString());
  }

  /// Step 2 — verify OTP, create account, get JWT.
  static Future<AuthResponse> step2({
    required int contact,
    required String otp,
  }) async {
    final response = await ApiConfig.post(
      '/users/onboarding/patient/step2/',
      headers: ApiConfig.jsonHeaders,
      body: jsonEncode({'contact': contact, 'otp': otp}),
    );
    final data = ApiConfig.handleResponse(response) as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(data);
    await _persist(auth);
    return auth;
  }

  /// Step 3 — complete profile (protected).
  static Future<void> step3(Map<String, dynamic> payload) async {
    final response = await ApiConfig.patch(
      '/users/onboarding/patient/step3/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode(payload),
    );
    ApiConfig.handleResponse(response);
  }

  // ── TOKEN REFRESH ──────────────────────────────────────────────────────────
  static Future<String> refreshToken() async {
    final refresh = await ApiConfig.getRefreshToken();
    final response = await ApiConfig.post(
      '/users/token/refresh/',
      headers: ApiConfig.jsonHeaders,
      body: jsonEncode({'refresh': refresh}),
    );
    final data = ApiConfig.handleResponse(response) as Map<String, dynamic>;
    final newAccess = data['access']?.toString() ?? '';
    await ApiConfig.saveTokens(access: newAccess, refresh: refresh ?? '');
    return newAccess;
  }

  // ── CONVENIENCE WRAPPERS ───────────────────────────────────────────────────
  static Future<bool> isLoggedIn() => ApiConfig.isLoggedIn();
  static Future<String> getSavedName() => ApiConfig.getSavedName();
  static Future<String> getSavedContact() => ApiConfig.getSavedContact();
  static Future<void> clearAll() => ApiConfig.clearAll();

  static Future<void> _persist(AuthResponse auth) async {
    await ApiConfig.saveTokens(
      access: auth.accessToken,
      refresh: auth.refreshToken,
    );
    await ApiConfig.saveUserInfo(
      id: auth.user.id,
      name: auth.user.name,
      contact: auth.user.contact.toString(),
    );
  }
}
