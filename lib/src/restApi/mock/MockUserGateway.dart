import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/src/services/SecureStorage.dart';

class MockUserGateway implements UserGateway {

  List<SignedDevice> devices = [
    SignedDevice(
      id: 3,
      name: 'CZ-IOS',
      platform: DevicePlatform.ios,
      isWeb: false,
      lastSignIn: DateTime(2022, 6, 1, 12, 30),
      isCurrent: false,
    ),
    SignedDevice(
      id: 4,
      name: 'CZ-MacOS',
      platform: DevicePlatform.macos,
      isWeb: false,
      lastSignIn: DateTime(2023, 2, 1, 16, 35),
      isCurrent: false,
    )
  ];

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe, Device device) async {
    await Future.delayed(const Duration(seconds: 2));
    SecureStorage secureStorage = SecureStorage.instance;

    if (username.toLowerCase() == 'admin' && password.toLowerCase() == 'admin') {
      String token = '123456789';

      if (rememberMe) {
        secureStorage.set('token', token);
      }

      devices.add(SignedDevice(
        id: device.id,
        name: device.name,
        platform: device.platform,
        isWeb: device.isWeb,
        lastSignIn: DateTime.now(),
        isCurrent: true,
      ));

      return SignedUser(
        id: 1,
        firstName:'Karel',
        lastName:'Novak',
        username:username,
        token: token,
      );
    }

    secureStorage.remove('token');
    return null;
  }

  @override
  Future<SignedUser?> loginWithToken(String token) async {
    await Future.delayed(const Duration(seconds: 2));

    if (token.toLowerCase() == '123456789') {
      Device device = await DeviceInfo.getDevice();
      devices.add(
        SignedDevice(
          id: device.id,
          name: device.name,
          platform: device.platform,
          isWeb: device.isWeb,
          lastSignIn: DateTime.now(),
          isCurrent: true,
        )
      );

      return SignedUser(
          id: 1,
          firstName:'Karel',
          lastName:'Novak',
          username: 'admin',
          token: token,
      );
    }

    SecureStorage.instance.remove('token');
    return null;
  }

  @override
  Future<void> logout(String token) async {
    SecureStorage.instance.remove('token');
  }

  @override
  Future<void> logoutFromDevice(int deviceId) {
    for(Device device in devices) {
      if (device.id == deviceId) {
        devices.remove(device);
        break;
      }
    }
    return Future.delayed(const Duration(milliseconds: 100), () => {});
  }

  @override
  Future<List<SignedDevice>> getDevices() {
    return Future.delayed(const Duration(seconds: 1), () async {
      List<SignedDevice> sorted = devices.toList();
      sorted.sort((a, b) {
        return a.lastSignIn.compareTo(b.lastSignIn) * -1;
      },);
      return sorted;
    },);
  }
}