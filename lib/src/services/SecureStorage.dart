
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oes/src/services/LocalStorage.dart';

class SecureStorage {

  static final instance = SecureStorage._();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  SecureStorage._();

  Future<String?> get(String key) async {
    try {
      return storage.read(key: key);
    } on Exception {
      print('Warning -> Using LocalStorage instance of SecureStorage');
      return LocalStorage.instance.get(key);
    }
  }

  Future<void> set(String key, String value) async {
    try {
      await storage.write(key: key, value: value);
    } on Exception {
      print('Warning -> Using LocalStorage instance of SecureStorage');
      return LocalStorage.instance.set(key, value);
    }
  }

  Future<void> remove(String key) async {
    try {
      await storage.delete(key: key);
    } on Exception {
      print('Warning -> Using LocalStorage instance of SecureStorage');
      return LocalStorage.instance.remove(key);
    }
  }
}