import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides secure + local key-value storage.
/// Use [secureWrite]/[secureRead] for sensitive data (tokens).
/// Use [write]/[read] for non-sensitive preferences.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static SharedPreferences? _prefs;

  /// Must be called before using local storage methods.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// The already-initialised instance. `main()` awaits [init] before `runApp`,
  /// so every binding and repository can take this synchronously instead of
  /// re-awaiting `SharedPreferences.getInstance()` and registering itself a
  /// frame late — the local cart depends on being there before the first build.
  static SharedPreferences get prefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('StorageService.init() must run before prefs is read.');
    }
    return prefs;
  }

  // ── Token storage (secure) ────────────────────────────────
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveToken(String token) =>
      _secureStorage.write(key: _tokenKey, value: token);

  Future<String?> getToken() =>
      _secureStorage.read(key: _tokenKey);

  Future<void> saveRefreshToken(String token) =>
      _secureStorage.write(key: _refreshTokenKey, value: token);

  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: _refreshTokenKey);

  Future<void> deleteToken() =>
      _secureStorage.delete(key: _tokenKey);

  Future<void> clearAll() => _secureStorage.deleteAll();

  // ── Preference storage (local) ────────────────────────────
  void write(String key, dynamic value) {
    if (value is String) _prefs?.setString(key, value);
    if (value is bool) _prefs?.setBool(key, value);
    if (value is int) _prefs?.setInt(key, value);
    if (value is double) _prefs?.setDouble(key, value);
    if (value is List<String>) _prefs?.setStringList(key, value);
  }

  T? read<T>(String key) => _prefs?.get(key) as T?;

  void remove(String key) => _prefs?.remove(key);

  bool get hasToken =>
      _prefs?.containsKey(_tokenKey) ?? false;
}
