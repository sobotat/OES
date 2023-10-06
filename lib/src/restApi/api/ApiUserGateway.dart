
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/services/SecureStorage.dart';

class ApiUserGateway implements UserGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api';

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe, Device device) async {

    RequestResult result = await HttpRequest.instance.post('$basePath/auth/login',
      data: {
        'username': username,
        'password': password,
        'deviceRequest': device.toMap()..remove('id')
      },
    );

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-loginWithPassword] ${result.statusCode} -> ${result.message}');
      await SecureStorage.instance.remove('token');
      return null;
    }

    try {
      SignedUser user = SignedUser.fromJson(result.data);
      await SecureStorage.instance.set('token', user.token);

      return user;
    } on Exception {
      return null;
    }
  }

  @override
  Future<SignedUser?> loginWithToken(String token) async {
    RequestResult result = await HttpRequest.instance.post('$basePath/auth/tokenLogin',
      options: AuthHttpRequestOptions(token: token)
    );

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-loginWithToken] ${result.statusCode} -> ${result.message}');
      await SecureStorage.instance.remove('token');
      return null;
    }

    try {
      SignedUser user = SignedUser.fromJson(result.data);
      await SecureStorage.instance.set('token', user.token);

      return user;
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> logout(String token) async {
    SecureStorage.instance.remove('token');

    await HttpRequest.instance.post('$basePath/auth/tokenLogout',
        options: AuthHttpRequestOptions(token: token)
    );
  }

  @override
  Future<void> logoutFromDevice(String deviceToken) async {
    await HttpRequest.instance.post('$basePath/auth/tokenLogout',
        options: AuthHttpRequestOptions(token: deviceToken)
    );
  }

  @override
  Future<List<SignedDevice>> getDevices(String token) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/session/getUserSessions',
        options: AuthHttpRequestOptions(token: token)
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [User-getDevices] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (result.statusCode != 200 || result.data is! List<dynamic>) {
      debugPrint('Api Error: [User-getDevices] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<SignedDevice> devices = [];
    for(Map<String, dynamic> json in result.data) {
        devices.add(SignedDevice.fromJson(json));
    }

    return devices;
  }

  @override
  Future<User?> getUser(int userId) {
    // TODO: implement getUser
    throw UnimplementedError();
  }

}