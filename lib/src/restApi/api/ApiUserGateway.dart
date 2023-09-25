
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

class ApiUserGateway implements UserGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/user';

  @override
  Future<SignedUser?> loginWithToken(String token) async {
    RequestResult result = await HttpRequest.instance.get(basePath,
      queryParameters: {
        'token': token,
      }
    );

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-loginWithToken] ${result.statusCode} -> ${result.message}');
      return null;
    }

    try {
      SignedUser user = SignedUser.fromJson(result.data);
      await LocalStorage.instance.set('token', user.token);

      return user;
    } on Exception {
      return null;
    }
  }

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe, Device device) async {
    RequestResult result = await HttpRequest.instance.get(basePath,
      queryParameters: {
        'username': username,
        'password': password,
        'rememberMe': rememberMe,
        'device': device.toMap()
      },
    );

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-loginWithToken] ${result.statusCode} -> ${result.message}');
      return null;
    }

    try {
      SignedUser user = SignedUser.fromJson(result.data);
      await LocalStorage.instance.set('token', user.token);

      return user;
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    LocalStorage.instance.remove('token');
  }

  @override
  Future<void> logoutFromDevice(int deviceId) {
    // TODO: implement logoutFromDevice
    throw UnimplementedError();
  }

  @override
  Future<List<SignedDevice>> getDevices() {
    // TODO: implement getSignedDevices
    throw UnimplementedError();
  }

}