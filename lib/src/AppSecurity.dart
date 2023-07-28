import 'package:flutter/cupertino.dart';
import 'package:oes/Src/Objects/User.dart';
import 'package:oes/Src/RestApi/Temp/UserDAOTemp.dart';
import 'package:oes/Src/RestApi/UserDAO.dart';

class AppSecurity extends ChangeNotifier {

  static final AppSecurity instance = AppSecurity();

  UserDAO userDAO = UserDAOTemp();
  User? user;
  bool isInit = false;

  Future<void> init() async {
    user = await userDAO.getUser();
    isInit = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    user = await userDAO.login(username, password);
    notifyListeners();
    return user == null ? false : true;
  }

  Future<void> logout() async {
    if (user == null) {
      return;
    }

    await userDAO.logout();
    user = null;
    notifyListeners();
  }

  bool isLoggedIn(){
    return user == null ? false : true;
  }

}