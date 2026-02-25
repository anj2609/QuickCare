import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';

/// User profile, medical profile, address, and account management.
class UserService {
  UserService._();

  // ── Profile ────────────────────────────────────────────────────────────────

  /// GET /users/me/
  static Future<UserModel> getMe() async {
    final r = await ApiConfig.get(
      '/users/me/',
      headers: await ApiConfig.authHeaders(),
    );
    return UserModel.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// PUT /users/me/
  static Future<UserModel> updateMe(Map<String, dynamic> payload) async {
    final r = await ApiConfig.put(
      '/users/me/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode(payload),
    );
    return UserModel.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  // ── Medical Profile ────────────────────────────────────────────────────────

  /// GET /users/me/medical-profile/
  static Future<MedicalProfile> getMedicalProfile() async {
    final r = await ApiConfig.get(
      '/users/me/medical-profile/',
      headers: await ApiConfig.authHeaders(),
    );
    return MedicalProfile.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// PUT /users/me/medical-profile/
  static Future<MedicalProfile> updateMedicalProfile(
    Map<String, dynamic> payload,
  ) async {
    final r = await ApiConfig.put(
      '/users/me/medical-profile/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode(payload),
    );
    return MedicalProfile.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  // ── Check user exists ──────────────────────────────────────────────────────

  /// GET /users/check/?contact=...
  static Future<bool> checkUserByContact(int contact) async {
    final r = await ApiConfig.get(
      '/users/check/?contact=$contact',
      headers: ApiConfig.jsonHeaders,
    );
    final data = ApiConfig.handleResponse(r);
    return (data is Map) && data['exists'] == true;
  }

  // ── Password ───────────────────────────────────────────────────────────────

  /// PUT /users/password/change/
  static Future<void> changePassword(String newPassword) async {
    final r = await ApiConfig.put(
      '/users/password/change/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode({'password': newPassword}),
    );
    ApiConfig.handleResponse(r);
  }

  // ── Addresses ──────────────────────────────────────────────────────────────

  /// GET /users/address/
  static Future<List<AddressModel>> listAddresses() async {
    final r = await ApiConfig.get(
      '/users/address/',
      headers: await ApiConfig.authHeaders(),
    );
    final data = ApiConfig.handleResponse(r);
    if (data is List) {
      return data
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// POST /users/address/
  static Future<AddressModel> createAddress(AddressModel address) async {
    final r = await ApiConfig.post(
      '/users/address/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode(address.toJson()),
    );
    return AddressModel.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// PUT /users/address/<id>/
  static Future<AddressModel> updateAddress(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final r = await ApiConfig.put(
      '/users/address/$id/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode(payload),
    );
    return AddressModel.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// DELETE /users/address/<id>/
  static Future<void> deleteAddress(String id) async {
    final r = await ApiConfig.delete(
      '/users/address/$id/',
      headers: await ApiConfig.authHeaders(),
    );
    ApiConfig.handleResponse(r);
  }
}
