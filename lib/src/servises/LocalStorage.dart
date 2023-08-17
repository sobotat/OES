import 'package:oes/src/exceptions/NotInitException.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  static final instance = LocalStorage._();

  SharedPreferences? _preferences;

  LocalStorage._() {
    SharedPreferences.getInstance().then((value) => _preferences);
  }

  String? get(String key) {
    if (_preferences == null) {
      throw NotInitException(message: 'SharedPreferences are not Init');
    }

    return _preferences!.getString(key);
  }

  void set(String key, String value) {
    if (_preferences == null) {
      throw NotInitException(message: 'SharedPreferences are not Init');
    }

    _preferences!.setString(key, value);
  }

}