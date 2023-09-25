
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oes/src/services/LocalStorage.dart';

class SecureStorage {

  static final instance = SecureStorage._();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  SecureStorage._();

  Future<String?> get(String key) async {
    return storage.read(key: key)
      .onError((error, stackTrace) {
        print('Warning -> Using LocalStorage instance of SecureStorage');
        return LocalStorage.instance.get(key);
    });
  }

  Future<void> set(String key, String value) async {
    await storage.write(key: key, value: value)
      .onError((error, stackTrace) {
        print('Warning -> Using LocalStorage instance of SecureStorage');
        return LocalStorage.instance.set(key, value);
    });
  }

  Future<void> remove(String key) async {
    await storage.delete(key: key)
      .onError((error, stackTrace) {
        print('Warning -> Using LocalStorage instance of SecureStorage');
        return LocalStorage.instance.remove(key);
    });
  }
}