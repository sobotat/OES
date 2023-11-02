import 'package:oes/config/AppApi.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/PagedData.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/api/ApiUserGateway.dart';
import 'package:oes/src/restApi/mock/MockUserGateway.dart';

abstract class UserGateway {

  static final UserGateway instance = AppApi.instance.useMockApi ? MockUserGateway() : ApiUserGateway();

  Future<User?> getUser(int userId);
  Future<PagedData<User>?> getAllUsers(int index, {int? count, List<UserRole>? roles});

  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe, Device device);
  Future<SignedUser?> loginWithToken(String token);

  Future<void> logout(String token);
  Future<void> logoutFromDevice(String deviceToken);

  Future<List<SignedDevice>> getDevices(String token);
}