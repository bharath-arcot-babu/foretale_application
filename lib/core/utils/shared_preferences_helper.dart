import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic method to save any type of data
  static Future<bool> setValue<T>(String key, T value) async {
    if (_prefs == null) await init();

    if (value is String) {
      return await _prefs!.setString(key, value);
    } else if (value is int) {
      return await _prefs!.setInt(key, value);
    } else if (value is double) {
      return await _prefs!.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs!.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs!.setStringList(key, value);
    }
    return false;
  }

  // Generic method to get any type of data
  static T? getValue<T>(String key, T defaultValue) {
    if (_prefs == null) return defaultValue;

    if (T == String) {
      return _prefs!.getString(key) as T? ?? defaultValue;
    } else if (T == int) {
      return _prefs!.getInt(key) as T? ?? defaultValue;
    } else if (T == double) {
      return _prefs!.getDouble(key) as T? ?? defaultValue;
    } else if (T == bool) {
      return _prefs!.getBool(key) as T? ?? defaultValue;
    } else if (T == List<String>) {
      return _prefs!.getStringList(key) as T? ?? defaultValue;
    }
    return defaultValue;
  }

  // Remove a value
  static Future<bool> removeValue(String key) async {
    if (_prefs == null) await init();
    return await _prefs!.remove(key);
  }

  // Clear all data
  static Future<bool> clearAll() async {
    if (_prefs == null) await init();
    return await _prefs!.clear();
  }

  // Check if a key exists
  static bool containsKey(String key) {
    if (_prefs == null) return false;
    return _prefs!.containsKey(key);
  }
}
