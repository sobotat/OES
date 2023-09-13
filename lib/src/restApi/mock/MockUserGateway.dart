import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/src/services/LocalStorage.dart';

class MockUserGateway implements UserGateway {

  @override
  Future<SignedUser?> getUser() async {
    String token = await LocalStorage.instance.get('token') ?? '';

    return (token != '') ? loginWithToken(token) : null;
  }

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe) async {
    await Future.delayed(const Duration(seconds: 2));
    LocalStorage localStorage = LocalStorage.instance;

    if (username.toLowerCase() == 'admin' && password.toLowerCase() == 'admin') {
      String token = '123456789';

      if (rememberMe) {
        localStorage.set('token', token);
      }

      return SignedUser(
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
  Future<SignedUser?> loginWithToken(String token) async {
    await Future.delayed(const Duration(seconds: 2));

    if (token.toLowerCase() == '123456789') {
      return SignedUser(
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
  Future<List<Device>> getSignedDevices() {
    return Future.delayed(const Duration(seconds: 1), () async {
      List<Device> out = [];

      DeviceInfo deviceInfo = await DeviceInfo.getInfo();
      out.add(Device(
        id: 1000,
        name: deviceInfo.name,
        platform: deviceInfo.platform,
        isWeb: deviceInfo.isWeb,
        lastSignIn: DateTime.now())
      );

      List<Device> other = [
        Device(
            id: 3,
            name: 'CZ-IOS',
            platform: DevicePlatform.ios,
            isWeb: false,
            lastSignIn: DateTime.now()
        ),
        Device(
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