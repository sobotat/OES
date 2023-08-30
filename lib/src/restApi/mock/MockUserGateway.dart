import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/src/services/LocalStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserGateway implements UserGateway {

  static final instance = MockUserGateway._();

  MockUserGateway._();

  @override
  Future<User?> getUser() async {
    String token = await LocalStorage.instance.get('token') ?? '';

    return (token != '') ? loginWithToken(token) : null;
  }

  @override
  Future<User?> loginWithUsernameAndPassword(String username, String password, bool rememberMe) async {
    await Future.delayed(const Duration(seconds: 2));
    LocalStorage localStorage = LocalStorage.instance;

    if (username.toLowerCase() == 'admin' && password.toLowerCase() == 'admin') {
      String token = '123456789';

      if (rememberMe) {
        localStorage.set('token', token);
      }

      return User(
        id: 1,
        firstName:'Karel',
        lastName:'Novak',
        username:username,
        token: token,
      );
    }

    localStorage.remove('token');
    return null;
  }

  @override
  Future<User?> loginWithToken(String token) async {
    await Future.delayed(const Duration(seconds: 2));

    if (token.toLowerCase() == '123456789') {
      return User(
          id: 1,
          firstName:'Karel',
          lastName:'Novak',
          username: 'admin',
          token: token,
      );
    }

    LocalStorage.instance.remove('token');
    return null;
  }

  @override
  Future<void> logout() async {
    LocalStorage.instance.remove('token');
  }

  @override
  Future<List<SignedDevice>> getSignedDevices() {
    return Future.delayed(const Duration(seconds: 1), () async {
      List<SignedDevice> out = [];

      DeviceInfo deviceInfo = await DeviceInfo.getInfo();
      out.add(SignedDevice(
        id: 1000,
        name: deviceInfo.name,
        platform: deviceInfo.platform,
        isWeb: deviceInfo.isWeb,
        lastSignIn: DateTime.now())
      );

      List<SignedDevice> other = [
        SignedDevice(
            id: 3,
            name: 'CZ-IOS',
            platform: DevicePlatform.ios,
            isWeb: false,
            lastSignIn: DateTime.now()
        ),
        SignedDevice(
            id: 4,
            name: 'CZ-MacOS',
            platform: DevicePlatform.macos,
            isWeb: false,
            lastSignIn: DateTime.now()
        )
      ];

      out.addAll(other);
      return out;
    },);
  }
}