
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/PagedData.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/services/LocalStorage.dart';

class ApiUserGateway implements UserGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api';

  @override
  Future<User?> loginWithUsernameAndPassword(String username, String password, Device device) async {
    RequestResult result = await HttpRequest.instance.post('$basePath/auth/login',
      data: {
        'username': username,
        'password': password,
        'deviceRequest': device.toMap()..remove('id')
      },
    );

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-loginWithPassword] ${result.statusCode} -> ${result.message}');
      await LocalStorage.instance.remove('token');
      return null;
    }

    try {
      User user = User.fromJson(result.data);
      await LocalStorage.instance.set('token', result.data['token']);

      return user;
    } on Exception {
      return null;
    }
  }

  @override
  Future<User?> loginWithToken(String token) async {
    RequestResult result = await HttpRequest.instance.post('$basePath/auth/tokenLogin',
      options: AuthHttpRequestOptions(token: token)
    );

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-loginWithToken] ${result.statusCode} -> ${result.message}');
      await LocalStorage.instance.remove('token');
      return null;
    }

    try {
      User user = User.fromJson(result.data);
      await LocalStorage.instance.set('token', result.data['token']);

      return user;
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> logout(String token) async {
    // LocalStorage.instance.remove('token');

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

    List<SignedDevice> sorted = devices.toList();
    sorted.sort((a, b) {
      return a.lastSignIn.compareTo(b.lastSignIn) * -1;
    },);
    return sorted;
  }

  @override
  Future<User?> getUser(int userId) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/users/$userId',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken())
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [User-getUser] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-getUser] ${result.statusCode} -> ${result.message}');
      return null;
    }
    
    return User.fromJson(result.data);
  }

  @override
  Future<PagedData<User>?> getAllUsers(int index, {int? count, List<UserRole>? roles}) async {

    Map<String, dynamic> query = {
      'page': index,
      'pageSize': count ?? 15,
      'userRoles': (roles ?? const [UserRole.student, UserRole.teacher, UserRole.admin]).map((e) => e.index).toList(),
    };

    RequestResult result = await HttpRequest.instance.get('$basePath/users',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      queryParameters: query,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [User-getAllUsers] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-getAllUsers] ${result.statusCode} -> ${result.message}');
      return null;
    }

    PagedData<User> users = PagedData.fromJson(result.data);

    for(Map<String, dynamic> userJson in result.data['items']) {
        users.data.add(User.fromJson(userJson));
    }

    return users;
  }

  @override
  Future<PagedData<User>?> findUsers(int index, String text, {int? count, List<UserRole>? roles}) async {

    Map<String, dynamic> query = {
      'page': index,
      'pageSize': count ?? 15,
      'userRoles': (roles ?? const [UserRole.student, UserRole.teacher, UserRole.admin]).map((e) => e.index).toList(),
      'search': text,
    };

    RequestResult result = await HttpRequest.instance.get('$basePath/users/search',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      queryParameters: query,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [User-getAllUsers] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [User-getAllUsers] ${result.statusCode} -> ${result.message}');
      return null;
    }

    PagedData<User> users = PagedData.fromJson(result.data);

    for(Map<String, dynamic> userJson in result.data['items']) {
      users.data.add(User.fromJson(userJson));
    }

    return users;
  }

}