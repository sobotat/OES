import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserGatewayTemp implements UserGateway {

  @override
  Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token') ?? '';

    return (token != '') ? loginWithToken(token) : null;
  }

  @override
  Future<User?> loginWithUsernameAndPassword(String username, String password, bool rememberMe) async {
    await Future.delayed(const Duration(seconds: 2));
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (username.toLowerCase() == 'admin' && password.toLowerCase() == 'admin') {
      String token = '123456789';

      if (rememberMe) {
        prefs.setString('token', token);
      }

      return User(
        id: 1,
        firstName:'Karel',
        lastName:'Novak',
        username:username,
        token: token,
      );
    }

    prefs.remove('token');
    return null;
  }

  @override
  Future<User?> loginWithToken(String token) async {
    await Future.delayed(const Duration(seconds: 2));
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (token.toLowerCase() == '123456789') {
      return User(
          id: 1,
          firstName:'Karel',
          lastName:'Novak',
          username: 'admin',
          token: token,
      );
    }

    prefs.remove('token');
    return null;
  }

  @override
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }
}