
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/services/LocalStorage.dart';
import 'package:oes/src/services/SecureStorage.dart';

class ApiUserGateway implements UserGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/user';

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe, Device device) async {

    RequestResult result = await HttpRequest.instance.post('$basePath/login',
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
    RequestResult result = await HttpRequest.instance.post('$basePath/TokenLogin',
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

    await HttpRequest.instance.post('$basePath/TokenLogout',
        options: AuthHttpRequestOptions(token: token)
    );
  }

  @override
  Future<void> logoutFromDevice(String deviceToken) async {
    await HttpRequest.instance.post('$basePath/TokenLogout',
        options: AuthHttpRequestOptions(token: deviceToken)
    );
  }

  @override
  Future<List<SignedDevice>> getDevices() async {
    return [];
  }

}