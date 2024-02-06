
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';

class ApiTestGateway implements TestGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/test';

  @override
  Future<Test?> get(int courseId, int id, {String? password}) async {
    Map<String, dynamic> query = {
      'courseId': courseId,
    };

    if (password != null) {
      query.addAll({'password': password,});
    }

    RequestResult result = await HttpRequest.instance.get('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: query,
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
  Future<Test?> create(int courseId, Test test, String password) async {

    test.created = DateTime.now();
    Map<String, dynamic> data = test.toMap();
    data.remove('id');
    data.remove('type');
    data['password'] = password;
    for (Map<String, dynamic> question in data['questions']) {
      question.remove('id');
      for(Map<String, dynamic> option in question['options']) {
        option.remove('id');
      }
    }

    RequestResult result = await HttpRequest.instance.post(basePath,
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
  Future<Test?> update(int courseId, Test test, String password) async {

    Map<String, dynamic> data = test.toMap();
    data.remove('id');
    data.remove('type');
    data['password'] = password;
    for (Map<String, dynamic> question in data['questions']) {
      question.remove('id');
      for(Map<String, dynamic> option in question['options']) {
        option.remove('id');
      }
    }

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

    if (!result.checkOk()) {
      debugPrint('Api Error: [Test-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return get(courseId, test.id);
  }

  @override
  Future<bool> submit(int courseId, int id, List<AnswerOption> answers) async {

    Map<String, dynamic> query = {
      'testId': id,
      'answers': answers.map((e) => e.toMap()).toList(),
    };

    RequestResult result = await HttpRequest.instance.post('$basePath/submit',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        'courseId': courseId,
      },
      data: query,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-submit] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Test-submit] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<bool> delete(int courseId, int id) async {
    RequestResult result = await HttpRequest.instance.delete('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        'courseId':courseId,
      },
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Test-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<TestInfo?> getInfo(int courseId, int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/info',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        'courseId':courseId,
      },
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-getInfo] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Test-getInfo] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return TestInfo.fromJson(result.data);
  }

}