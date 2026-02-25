import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thrown when the server returns a non-2xx response.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

/// Centralized API configuration — single place for base URL, headers, and
/// shared HTTP helpers used by every service class.
class ApiConfig {
  ApiConfig._();

  static const baseUrl = 'https://quickcare-kzis.onrender.com/api';
  static const _timeout = Duration(seconds: 20);
  static const _storage = FlutterSecureStorage();

  // ── Storage keys ───────────────────────────────────────────────────────────
  static const keyAccess = 'jwt_access';
  static const keyRefresh = 'jwt_refresh';
  static const keyUserId = 'user_id';
  static const keyName = 'user_name';
  static const keyContact = 'user_contact';

  // ── Headers ────────────────────────────────────────────────────────────────
  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> authHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Multipart auth headers (no Content-Type — http package sets it).
  static Future<Map<String, String>> multipartAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Logging ────────────────────────────────────────────────────────────────
  static void _logRequest(String method, String url, {Object? body}) {
    debugPrint('┌─── $method $url');
    if (body != null) debugPrint('│ BODY: $body');
  }

  static void _logResponse(http.Response r) {
    debugPrint('│ STATUS: ${r.statusCode}');
    debugPrint('│ RESPONSE: ${r.body}');
    debugPrint('└───');
  }

  // ── Response handler ───────────────────────────────────────────────────────
  /// Decodes JSON, returns body on 2xx, throws [ApiException] otherwise.
  ///
  /// Handles two common error formats:
  /// - `{ "message": "Human-readable error description." }`
  /// - `{ "field_name": ["This field is required."] }` (field validation)
  static dynamic handleResponse(http.Response response) {
    dynamic body;
    try {
      body = response.body.isEmpty ? {} : jsonDecode(response.body);
    } catch (_) {
      body = {};
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    String msg = 'Error ${response.statusCode}. Please try again.';
    if (body is Map) {
      // Try known top-level error keys first
      final topLevel =
          body['detail']?.toString() ??
          body['message']?.toString() ??
          body['non_field_errors']?.toString() ??
          body['error']?.toString();
      if (topLevel != null) {
        msg = topLevel;
      } else {
        // Field validation: { "field_name": ["error1", "error2"], ... }
        final parts = <String>[];
        body.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            final errors = value.map((e) => e.toString()).join(', ');
            parts.add('$key: $errors');
          } else if (value is String) {
            parts.add('$key: $value');
          }
        });
        if (parts.isNotEmpty) msg = parts.join('\n');
      }
    }
    debugPrint('⚠️ API ERROR: $msg (status ${response.statusCode})');
    throw ApiException(msg, response.statusCode);
  }

  // ── Convenience HTTP methods (with timeout + logging) ──────────────────────
  static Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$path';
    _logRequest('GET', url);
    final r = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(_timeout);
    _logResponse(r);
    return r;
  }

  static Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = '$baseUrl$path';
    _logRequest('POST', url, body: body);
    final r = await http
        .post(Uri.parse(url), headers: headers, body: body)
        .timeout(_timeout);
    _logResponse(r);
    return r;
  }

  static Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = '$baseUrl$path';
    _logRequest('PUT', url, body: body);
    final r = await http
        .put(Uri.parse(url), headers: headers, body: body)
        .timeout(_timeout);
    _logResponse(r);
    return r;
  }

  static Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = '$baseUrl$path';
    _logRequest('PATCH', url, body: body);
    final r = await http
        .patch(Uri.parse(url), headers: headers, body: body)
        .timeout(_timeout);
    _logResponse(r);
    return r;
  }

  static Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$path';
    _logRequest('DELETE', url);
    final r = await http
        .delete(Uri.parse(url), headers: headers)
        .timeout(_timeout);
    _logResponse(r);
    return r;
  }

  // ── Token persistence ──────────────────────────────────────────────────────
  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) => Future.wait([
    _storage.write(key: keyAccess, value: access),
    _storage.write(key: keyRefresh, value: refresh),
  ]);

  static Future<void> saveUserInfo({
    required String id,
    required String name,
    required String contact,
  }) => Future.wait([
    _storage.write(key: keyUserId, value: id),
    _storage.write(key: keyName, value: name),
    _storage.write(key: keyContact, value: contact),
  ]);

  static Future<String?> getAccessToken() => _storage.read(key: keyAccess);
  static Future<String?> getRefreshToken() => _storage.read(key: keyRefresh);
  static Future<String> getSavedName() async =>
      (await _storage.read(key: keyName)) ?? '';
  static Future<String> getSavedContact() async =>
      (await _storage.read(key: keyContact)) ?? '';

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: keyAccess);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() => _storage.deleteAll();
}
