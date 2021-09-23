import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  late SharedPreferences prefs;

  Future<bool> setSharedPreferencesBool(String key, bool value) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  Future<bool> setSharedPreferencesString(String key, String value) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<bool> setSharedPreferencesInt(String key, int value) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, value);
  }

  getSharedPreferencesBool(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  getSharedPreferencesString(String key) async {
    prefs = await SharedPreferences.getInstance();
    return (prefs.getString(key) ?? '');
  }

  getSharedPreferencesInt(String key) async {
    prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(key) ?? 0);
  }

  deleteSharedPreferencesItem(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
