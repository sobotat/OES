
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/UserGateway.dart';

class ApiUserGateway implements UserGateway {

  @override
  Future<List<Device>> getSignedDevices() {
    // TODO: implement getSignedDevices
    throw UnimplementedError();
  }

  @override
  Future<SignedUser?> getUser() {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<SignedUser?> loginWithToken(String token) {
    // TODO: implement loginWithToken
    throw UnimplementedError();
  }

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe) {
    // TODO: implement loginWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

}