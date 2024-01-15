import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/PagedData.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/src/services/SecureStorage.dart';

class MockUserGateway implements UserGateway {

  List<SignedDevice> devices = [
    SignedDevice(
      name: 'CZ-IOS',
      platform: DevicePlatform.ios,
      isWeb: false,
      deviceToken: '1234${0}',
      lastSignIn: DateTime(2022, 6, 1, 12, 30),
    ),
    SignedDevice(
      name: 'CZ-MacOS',
      platform: DevicePlatform.macos,
      isWeb: false,
      deviceToken: '1234${1}',
      lastSignIn: DateTime(2023, 2, 1, 16, 35),
    )
  ];

  List<User> users = [
    User(id: 10, firstName: 'Karel', lastName: 'New', username: 'karel.new', role: UserRole.teacher),
    User(id: 20, firstName: 'Mark', lastName: 'Test', username: 'mark.test', role: UserRole.teacher),
    User(id: 30, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe', role: UserRole.admin),
    User(id: 12, firstName: 'Karel', lastName: 'Student', username: 'karel.student', role: UserRole.student),
    User(id: 23, firstName: 'Mark', lastName: 'Student', username: 'mark.student', role: UserRole.student),
    User(id: 34, firstName: 'Jane', lastName: 'Student', username: 'jane.student', role: UserRole.student),
  ];

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe, Device device) async {
    await Future.delayed(const Duration(seconds: 2));
    SecureStorage secureStorage = SecureStorage.instance;

    List<User> possibleUsers = users.where((element) => element.username == username && password == '1234').toList();
    if (possibleUsers.isNotEmpty) {
      String token = possibleUsers.first.id.toString();

      if (rememberMe) {
        secureStorage.set('token', token);
      }

      devices.add(SignedDevice(
        name: device.name,
        platform: device.platform,
        isWeb: device.isWeb,
        deviceToken: '1234${devices.length}',
        lastSignIn: DateTime.now(),
      ));

      return SignedUser(
        id: possibleUsers.first.id,
        firstName: possibleUsers.first.firstName,
        lastName: possibleUsers.first.lastName,
        username: possibleUsers.first.username,
        token: token,
      );
    }

    secureStorage.remove('token');
    return null;
  }

  @override
  Future<SignedUser?> loginWithToken(String token) async {
    await Future.delayed(const Duration(seconds: 2));

    List<User> possibleUsers = users.where((element) => element.id.toString() == token).toList();
    if (possibleUsers.isNotEmpty) {
      Device device = await DeviceInfo.getDevice();
      devices.add(
        SignedDevice(
          name: device.name,
          platform: device.platform,
          isWeb: device.isWeb,
          deviceToken: '1234${devices.length}',
          lastSignIn: DateTime.now(),
        )
      );

      return SignedUser(
        id: possibleUsers.first.id,
        firstName: possibleUsers.first.firstName,
        lastName: possibleUsers.first.lastName,
        username: possibleUsers.first.username,
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
  Future<void> logoutFromDevice(String deviceToken) {
    for(SignedDevice device in devices) {
      if (device.deviceToken == deviceToken) {
        devices.remove(device);
        break;
      }
    }
    return Future.delayed(const Duration(milliseconds: 100), () => {});
  }

  @override
  Future<List<SignedDevice>> getDevices(String token) {
    return Future.delayed(const Duration(seconds: 1), () async {
      List<SignedDevice> sorted = devices.toList();
      sorted.sort((a, b) {
        return a.lastSignIn.compareTo(b.lastSignIn) * -1;
      },);
      return sorted;
    },);
  }

  @override
  Future<User?> getUser(int userId) async {
    return users.where((element) => element.id == userId).single;
  }

  @override
  Future<PagedData<User>?> getAllUsers(int index, {int? count, List<UserRole>? roles}) async {

    if (!users.contains(AppSecurity.instance.user!)) {
      users.add(AppSecurity.instance.user!);
    }

    PagedData<User> data = PagedData<User>(
      page: 1,
      pageSize: users.length,
      havePrev: false,
      haveNext: false,
    );
    data.data = users;
    return data;
  }

  @override
  Future<PagedData<User>?> findUsers(int index, String text, {int? count, List<UserRole>? roles}) {
    // TODO: implement findUsers
    throw UnimplementedError();
  }
}