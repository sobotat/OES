import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/temp/UserGatewayTemp.dart';

abstract class UserGateway {

  static UserGateway gateway = UserGatewayTemp();

  Future<User?> getUser();

  Future<User?> loginWithUsernameAndPassword(String username, String password, bool rememberMe);

  Future<User?> loginWithToken(String token);

  Future<void> logout();


}