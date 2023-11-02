
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
      debugPrint('Api Error: [Test-getTest] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Test-getTest] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Test.fromJson(result.data);
  }

}