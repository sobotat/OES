
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {

  static final instance = SecureStorage._();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  SecureStorage._();

  Future<String?> get(String key) async {
    return await storage.read(key: key);
  }

  Future<void> set(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<void> remove(String key) async {
    await storage.delete(key: key);
  }
}