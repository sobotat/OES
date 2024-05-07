import 'package:flutter/cupertino.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/config/AppRouter.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/src/services/SecureStorage.dart';

class AppSecurity extends ChangeNotifier {

  static final AppSecurity instance = AppSecurity();

  User? user;

  bool _isInit = false;
  bool get isInit => _isInit;

  Future<void> init() async {
    if (_isInit) {
      return;
    }

    String? token = await SecureStorage.instance.get('token');
    if (token != null) {
      if (!AppApi.instance.haveApiUrl()) {
        debugPrint("Did not get Organization Url -> Redirecting to Sign-In");
        AppRouter.instance.router.goNamed("sign-in", queryParameters: {
          'path': AppRouter.instance.activeUri,
        });

        _isInit = true;
        notifyListeners();
        return;
      }

      user = await UserGateway.instance.loginWithToken(token)
          .onError((error, stackTrace) {
        debugPrint("Failed to Sign in User by Token");
        return null;
      });
    }

    _isInit = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (!AppApi.instance.haveApiUrl()) {
      debugPrint("Did not get Organization Url -> Redirecting to Sign-In");
      AppRouter.instance.router.goNamed("sign-in", queryParameters: {
        'path': AppRouter.instance.activeUri,
      });

      notifyListeners();
      return false;
    }

    Device device = await DeviceInfo.getDevice();
    user = await UserGateway.instance.loginWithUsernameAndPassword(username, password, device)
      .onError((error, stackTrace) {
        debugPrint("Failed to Sign in User with Username and Password");
        return null;
      });

    if(user != null) {
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    if (user == null) return;
    await UserGateway.instance.logout(await getToken());
    user = null;
    notifyListeners();
  }

  Future<void> logoutFromDevice(String deviceToken) async {
    if(user != null) {
      String token = await getToken();
      var devices = (await UserGateway.instance.getDevices(token)).where((element) => element.deviceToken == deviceToken && element.deviceToken == token);
      if (devices.isNotEmpty) {
        logout();
      } else {
        await UserGateway.instance.logoutFromDevice(deviceToken);
      }
    }
    notifyListeners();
  }

  Future<String> getToken() async {
    return (await SecureStorage.instance.get("token")) ?? "";
  }

  bool isLoggedIn(){
    return user == null ? false : true;
  }
}