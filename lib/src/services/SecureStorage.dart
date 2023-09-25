
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oes/src/services/LocalStorage.dart';

class SecureStorage {

  static final instance = SecureStorage._();

  bool isSupported = true;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SecureStorage._();

  Future<void> init() async {
    await _storage.write(key: 'test-flutter_secure_storage', value: 'true')
      .then((value) {
        isSupported = true;
        _storage.delete(key: 'test-flutter_secure_storage');
      })
      .onError((error, stackTrace) {
        isSupported = false;
        print('Warning -> SecureStorage is not Supported');
      });
  }

  Future<String?> get(String key) async {
    if (!isSupported) {
      print('Warning -> Using LocalStorage instance of SecureStorage');
      return await LocalStorage.instance.get(key);
    }
    return await _storage.read(key: key);
  }

  Future<void> set(String key, String value) async {
    if (!isSupported) {
      print('Warning -> Using LocalStorage instance of SecureStorage');
      return await LocalStorage.instance.set(key, value);
    }
    await _storage.write(key: key, value: value);
  }

  Future<void> remove(String key) async {
    if (!isSupported) {
      print('Warning -> Using LocalStorage instance of SecureStorage');
      return await LocalStorage.instance.remove(key);
    }
    await _storage.delete(key: key);
  }
}