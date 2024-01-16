
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';

class ApiTestGateway implements TestGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/test';

  @override
  Future<Test?> get(int courseId, int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        'courseId':courseId,
      },
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Test-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Test.fromJson(result.data);
  }

  @override
  Future<Test?> create(int courseId, Test test) async {

    Map<String, dynamic> data = test.toMap();
    data.remove('id');

    RequestResult result = await HttpRequest.instance.post('$basePath/${test.id}',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        'courseId':courseId,
      },
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Test-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Test.fromJson(result.data);
  }

  @override
  Future<Test?> update(int courseId, Test test) async {

    Map<String, dynamic> data = test.toMap();

    RequestResult result = await HttpRequest.instance.put('$basePath/${test.id}',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        'courseId':courseId,
      },
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Test-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Test.fromJson(result.data);
  }

  @override
  Future<bool> submit(Test test) async {
    print("Submitting");
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

}