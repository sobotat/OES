import 'package:flutter/cupertino.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/UserGateway.dart';

class AppSecurity extends ChangeNotifier {

  static final AppSecurity instance = AppSecurity();

  User? user;
  bool _isInit = false;
  bool get isInit => _isInit;

  Future<void> init() async {
    if (_isInit) {
      return;
    }

    user = await UserGateway.gateway.getUser();
    _isInit = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    user = await UserGateway.gateway.loginWithUsernameAndPassword(username, password);
    notifyListeners();
    return user == null ? false : true;
  }

  Future<void> logout() async {
    if (user == null) {
      return;
    }

    await UserGateway.gateway.logout();
    user = null;
    notifyListeners();
  }

  bool isLoggedIn(){
    return user == null ? false : true;
  }
}