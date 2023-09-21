import 'package:flutter/cupertino.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/src/services/LocalStorage.dart';

class AppSecurity extends ChangeNotifier {

  static final AppSecurity instance = AppSecurity();

  SignedUser? user;
  Device? device;

  bool _isInit = false;
  bool get isInit => _isInit;

  Future<void> init() async {
    if (_isInit) {
      return;
    }

    String? token = await LocalStorage.instance.get('token');
    if (token != null) {
      user = await UserGateway.instance.loginWithToken(token);
      if (user != null) {
        device = await UserGateway.instance.getCurrentDevice();
      }
    }
    _isInit = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password, {bool? rememberMe}) async {
    Device device = await DeviceInfo.getDevice();
    user = await UserGateway.instance.loginWithUsernameAndPassword(username, password, rememberMe ?? true, device);

    if(user != null) {
      this.device = await UserGateway.instance.getCurrentDevice();
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    if (user == null) return;
    if (user!.token != null) {
      await UserGateway.instance.logout();
    }
    user = null;
    device = null;
    notifyListeners();
  }

  Future<void> logoutFromDevice(int deviceId) async {
    await UserGateway.instance.logoutFromDevice(deviceId);
    if(user != null) {
      user!.clearCache();
      if (device != null && device!.id == deviceId) {
        user = null;
        device = null;
      }
    }
    notifyListeners();
  }

  bool isLoggedIn(){
    return user == null ? false : true;
  }
}