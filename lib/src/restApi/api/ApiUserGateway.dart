
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/restApi/UserGateway.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';

class ApiUserGateway implements UserGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/course';

  @override
  Future<SignedUser?> loginWithToken(String token) async {
    RequestResult result = await HttpRequest.instance.get('$basePath', options: HttpRequestOptions(
      headers: {
        'Authorization': 'eyJVc2VySWQiOjEsIlVzZXJSb2xlIjoidGVhY2hlciIsIkNyZWF0aW9uIjoiMjAyMy0wOS0yM1QyMjo1Nzo0OS41OTM0NTg2KzAyOjAwIiwiRXhwaXJhdGlvbiI6IjIwMjMtMDktMjNUMjI6NTg6MzQuNTkzNDY0NCswMjowMCJ9|2360329f-4078-4107-8788-49ee8db003fc'
      }
    ));

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-loginWithToken] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return SignedUser.fromJson(result.data);
  }

  @override
  Future<SignedUser?> loginWithUsernameAndPassword(String username, String password, bool rememberMe, Device device) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/', queryParameters: {
      'username': username,
      'password': password,
      'rememberMe': rememberMe,
      'device': device.toMap()
    },);

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-loginWithToken] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return SignedUser.fromJson(result.data);
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
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