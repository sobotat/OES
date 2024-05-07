import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/PagedData.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/api/ApiUserGateway.dart';

abstract class UserGateway {

  static final UserGateway instance = ApiUserGateway();

  Future<User?> getUser(int userId);
  Future<PagedData<User>?> getAllUsers(int index, {int? count, List<UserRole>? roles});
  Future<PagedData<User>?> findUsers(int index, String text, {int? count, List<UserRole>? roles});

  Future<User?> loginWithUsernameAndPassword(String username, String password, Device device);
  Future<User?> loginWithToken(String token);

  Future<void> logout(String token);
  Future<void> logoutFromDevice(String deviceToken);

  Future<List<SignedDevice>> getDevices(String token);
}