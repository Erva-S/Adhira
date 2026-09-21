import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service wrapping SharedPreferences.
class LocalStorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── String ────────────────────────────────────────────────────
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  String? getString(String key) => _prefs?.getString(key);

  // ── Bool ──────────────────────────────────────────────────────
  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  bool? getBool(String key) => _prefs?.getBool(key);

  // ── Int ───────────────────────────────────────────────────────
  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  int? getInt(String key) => _prefs?.getInt(key);

  // ── Remove ────────────────────────────────────────────────────
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  bool containsKey(String key) => _prefs?.containsKey(key) ?? false;
}
