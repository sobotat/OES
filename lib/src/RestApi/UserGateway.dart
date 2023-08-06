import 'package:oes/Src/Objects/User.dart';
import 'package:oes/src/RestApi/Temp/UserGatewayTemp.dart';

abstract class UserGateway {

  static UserGateway gateway = UserGatewayTemp();

  Future<User?> getUser();

  Future<User?> loginWithUsernameAndPassword(String username, String password);

  Future<User?> loginWithToken(String token);

  Future<void> logout();


}