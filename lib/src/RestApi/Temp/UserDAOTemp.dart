
import 'package:oes/Src/Objects/User.dart';
import 'package:oes/Src/RestApi/UserDAO.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDAOTemp implements UserDAO {

  @override
  Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ?? '';
    await Future.delayed(const Duration(seconds: 2));

    return (username != '' && password != '') ? User(username, password) : null;
  }

  @override
  Future<User?> login(String username, String password) async {
    if (username.toLowerCase() == 'admin' && password.toLowerCase() == 'admin') {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('username', username);
      prefs.setString('password', password);

      return User('admin', 'admin');
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