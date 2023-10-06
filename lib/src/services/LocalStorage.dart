
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  static final instance = LocalStorage._();
  LocalStorage._();

  Future<String?> get(String key) async {
    var preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  Future<void> set(String key, String value) async {
    var preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
  }

  Future<void> remove(String key) async {
    var preferences = await SharedPreferences.getInstance();
    preferences.remove(key);
  }
}