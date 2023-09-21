
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/UserGateway.dart';

class ApiUserGateway implements UserGateway {

  @override
  Future<SignedUser?> loginWithToken(String token) {
    // TODO: implement loginWithToken
    throw UnimplementedError();
  }

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe, Device device) {
    // TODO: implement loginWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<void> logoutFromDevice(int deviceId) {
    // TODO: implement logoutFromDevice
    throw UnimplementedError();
  }

  @override
  Future<List<Device>> getDevices() {
    // TODO: implement getSignedDevices
    throw UnimplementedError();
  }

  @override
  Future<Device> getCurrentDevice() {
    // TODO: implement getCurrentDevice
    throw UnimplementedError();
  }

}