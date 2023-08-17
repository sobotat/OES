import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/mock/MockUserGateway.dart';

abstract class UserGateway {

  static UserGateway gateway = MockUserGateway.instance;

  Future<User?> getUser();

  Future<User?> loginWithUsernameAndPassword(String username, String password, bool rememberMe);

  Future<User?> loginWithToken(String token);

  Future<void> logout();

  Future<List<SignedDevice>> getSignedDevices();
}