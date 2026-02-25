import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper for user session data backed by flutter_secure_storage.
/// Token management lives in AuthService; this handles profile display fields.
class UserPrefs {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'user_name';
  static const _keyContact = 'user_contact';

  static Future<void> save({
    required String name,
    required String contact,
  }) async {
    await Future.wait([
      _storage.write(key: _keyName, value: name),
      _storage.write(key: _keyContact, value: contact),
    ]);
  }

  static Future<String> getName() async =>
      (await _storage.read(key: _keyName)) ?? '';

  static Future<String> getContact() async =>
      (await _storage.read(key: _keyContact)) ?? '';

  static Future<void> clear() async => _storage.deleteAll();
}
