import 'package:flutter/cupertino.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/src/services/SecureStorage.dart';

class AppSecurity extends ChangeNotifier {

  static final AppSecurity instance = AppSecurity();

  SignedUser? user;

  bool _isInit = false;
  bool get isInit => _isInit;

  Future<void> init() async {
    if (_isInit) {
      return;
    }

    String? token = await SecureStorage.instance.get('token');
    if (token != null) {
      user = await UserGateway.instance.loginWithToken(token);
    }
    _isInit = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password, {bool? rememberMe}) async {
    Device device = await DeviceInfo.getDevice();
    user = await UserGateway.instance.loginWithUsernameAndPassword(username, password, rememberMe ?? true, device);

    if(user != null) {
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    if (user == null) return;
    await UserGateway.instance.logout(user!.token);
    user = null;
    notifyListeners();
  }

  Future<void> logoutFromDevice(int deviceId) async {
    await UserGateway.instance.logoutFromDevice(deviceId);
    if(user != null) {
      var devices = (await user!.signedDevices).where((element) => element.id == deviceId && element.isCurrent);
      user!.clearCache();
      if (devices.isNotEmpty) {
        logout();
      }
    }
    notifyListeners();
  }

  bool isLoggedIn(){
    return user == null ? false : true;
  }
}