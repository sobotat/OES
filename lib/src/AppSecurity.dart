import 'package:shared_preferences/shared_preferences.dart';

class AppSecurity {

  static AppSecurity? instance;

  String username = '';
  String password = '';

  AppSecurity(){
    instance ??= this;
  }

  Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    password = prefs.getString('password') ?? '';
  }

  Future<bool> login(String username, String password) async {
    if (username.toLowerCase() == 'admin' && password.toLowerCase() == 'admin') {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      prefs.setString('username', username);
      prefs.setString('password', password);
      
      return true;
    }
    return false;
  }

  bool isLoggedIn(){
    return (username.toLowerCase() == 'admin' && password.toLowerCase() == 'admin');
  }

}