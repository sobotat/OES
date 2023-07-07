import 'package:oes/Src/Objects/User.dart';
import 'package:oes/Src/RestApi/Temp/UserDAOTemp.dart';
import 'package:oes/Src/RestApi/UserDAO.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSecurity {

  static final AppSecurity instance = AppSecurity();

  UserDAO userDAO = UserDAOTemp();
  User? user;

  Future<void> init() async {
    user = await userDAO.getUser();
  }

  Future<bool> login(String username, String password) async {
    user = await userDAO.login(username, password);
    return user == null ? false : true;
  }

  bool isLoggedIn(){
    return user == null ? false : true;
  }

}