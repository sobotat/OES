
import 'package:oes/Src/Objects/User.dart';
import 'package:oes/src/RestApi/UserGateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserGatewayTemp implements UserGateway {

  @override
  Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ?? '';

    return (username != '' && password != '') ? login(username, password) : null;
  }

  @override
  Future<User?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (username.toLowerCase() == 'admin' && password.toLowerCase() == 'admin') {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('username', username);
      prefs.setString('password', password);

      return User(
        id: 1,
        firstName:'Karel',
        lastName:'Novak',
        username:username,
        token: '123456789'
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove('username');
    prefs.remove('password');
  }

}