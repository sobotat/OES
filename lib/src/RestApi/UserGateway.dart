import 'package:oes/Src/Objects/User.dart';
import 'package:oes/src/RestApi/Temp/UserGatewayTemp.dart';

class UserGateway {

  static UserGateway gateway = UserGatewayTemp();

  Future<User?> getUser() async {
    throw UnimplementedError();
  }

  Future<User?> login(String username, String password) async {
    throw UnimplementedError();
  }

  Future<void> logout() async {
    throw UnimplementedError();
  }


}