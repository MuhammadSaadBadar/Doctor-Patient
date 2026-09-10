import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class StorageService extends GetxService {
  static StorageService? _instance;
  static StorageService get instance {
    _instance ??= Get.find<StorageService>();
    return _instance!;
  }

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ==================== GENERIC METHODS ====================

  String? _getString(String key) => _prefs.getString(key);
  Future<bool> _setString(String key, String value) async =>
      _prefs.setString(key, value);

  bool? _getBool(String key) => _prefs.getBool(key);
  Future<bool> _setBool(String key, bool value) async =>
      _prefs.setBool(key, value);

  int? _getInt(String key) => _prefs.getInt(key);
  Future<bool> _setInt(String key, int value) async =>
      _prefs.setInt(key, value);

  Future<bool> _remove(String key) async => _prefs.remove(key);

  // ==================== TOKEN STORAGE ====================

  String? get accessToken => _getString('access_token');
  Future<void> setAccessToken(String token) async =>
      await _setString('access_token', token);

  String? get refreshToken => _getString('refresh_token');
  Future<void> setRefreshToken(String token) async =>
      await _setString('refresh_token', token);

  // ==================== USER DATA ====================

  String? get userId => _getString('user_id');
  Future<void> setUserId(String id) async => await _setString('user_id', id);

  String? get userRole => _getString('user_role');
  Future<void> setUserRole(String role) async =>
      await _setString('user_role', role);

  String? get userEmail => _getString('user_email');
  Future<void> setUserEmail(String email) async =>
      await _setString('user_email', email);

  String? get userFirstName => _getString('user_first_name');
  Future<void> setUserFirstName(String firstName) async =>
      await _setString('user_first_name', firstName);

  String? get userLastName => _getString('user_last_name');
  Future<void> setUserLastName(String lastName) async =>
      await _setString('user_last_name', lastName);

  String get userFullName {
    final first = userFirstName ?? '';
    final last = userLastName ?? '';
    return '$first $last'.trim();
  }

  // ==================== LOGIN STATE ====================

  bool get isLoggedIn => _getBool('is_logged_in') ?? false;
  Future<void> setLoggedIn(bool status) async =>
      await _setBool('is_logged_in', status);

  // ==================== APP PREFERENCES ====================

  String? getTheme() => _getString('theme');
  Future<void> setTheme(String theme) async => await _setString('theme', theme);

  bool? getNotifications() => _getBool('notifications');
  Future<void> setNotifications(bool enabled) async =>
      await _setBool('notifications', enabled);

  String? getLanguage() => _getString('language');
  Future<void> setLanguage(String language) async =>
      await _setString('language', language);

  Locale? getLocale() {
    final lang = getLanguage();
    if (lang == 'ur_PK') return const Locale('ur', 'PK');
    if (lang == 'en_US') return const Locale('en', 'US');
    return null;
  }

  // ==================== CLEAR METHODS ====================

  /// Clear all authentication data (tokens, user info, login state)
  Future<void> clearAuth() async {
    await _remove('access_token');
    await _remove('refresh_token');
    await _remove('user_id');
    await _remove('user_role');
    await _remove('user_email');
    await _remove('user_first_name');
    await _remove('user_last_name');
    await _remove('is_logged_in');
  }

  /// Clear all app preferences (theme, notifications, language)
  Future<void> clearPreferences() async {
    await _remove('theme');
    await _remove('notifications');
    await _remove('language');
  }

  /// Clear EVERYTHING - all stored data
  Future<void> clearAll() async {
    await clearAuth();
    await clearPreferences();
  }

  /// Clear specific key
  Future<void> clearKey(String key) async => await _remove(key);

  /// Get all keys (for debugging)
  Set<String> getKeys() => _prefs.getKeys();

  /// Check if a key exists
  bool containsKey(String key) => _prefs.containsKey(key);

  // ==================== BATCH OPERATIONS ====================

  /// Save multiple values at once
  Future<void> saveAll(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        await _setString(key, value);
      } else if (value is bool) {
        await _setBool(key, value);
      } else if (value is int) {
        await _setInt(key, value);
      }
    }
  }

  /// Get multiple values at once
  Map<String, dynamic> getAll(List<String> keys) {
    final result = <String, dynamic>{};
    for (final key in keys) {
      final value = _prefs.get(key);
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }
}
