import 'package:oes/config/AppApi.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/api/ApiUserGateway.dart';
import 'package:oes/src/restApi/mock/MockUserGateway.dart';

abstract class UserGateway {

  static final UserGateway instance = AppApi.instance.useMuckApi ? MockUserGateway() : ApiUserGateway();

  Future<SignedUser?> getUser();

  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe);

  Future<SignedUser?> loginWithToken(String token);

  Future<void> logout();

  Future<List<Device>> getSignedDevices();
}