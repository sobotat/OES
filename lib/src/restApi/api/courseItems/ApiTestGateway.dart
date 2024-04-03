
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Review.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';

class ApiTestGateway implements TestGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/tests';
  String userBasePath = '${AppApi.instance.apiServerUrl}/api/users';

  @override
  Future<Test?> get(int id, {String? password}) async {
    Map<String, dynamic> query = password != null? {'password': password,} : {};

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
      if (result.statusCode == 423) throw Exception("Test is Locked");
      return null;
    }

    return Test.fromJson(result.data);
  }

  @override
  Future<List<TestSubmission>> getUserSubmission(int id, int userId) async {

    RequestResult result = await HttpRequest.instance.get('$userBasePath/$userId/test-submissions',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        "testId": id
      },
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-getUserSubmission] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (!result.checkOk() || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Test-getUserSubmission] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<TestSubmission> out = [];
    for(Map<String, dynamic> json in result.data) {
      out.add(TestSubmission.fromJson(json));
    }
    return out;
  }

  @override
  Future<List<AnswerOption>> getAnswers(int id, int submissionId) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/submissions/$submissionId',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-getAnswers] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (!result.checkOk() || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Test-getAnswers] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<AnswerOption> out = [];
    for(Map<String, dynamic> json in result.data) {
      out.add(AnswerOption.fromJson(json));
    }
    return out;
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
  Future<Test?> update(Test test, String password) async {

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

    return get(test.id);
  }

  @override
  Future<bool> submit(int id, List<AnswerOption> answers) async {

    Map<String, dynamic> query = {
      'testId': id,
      'answers': answers.map((e) => e.toMap()).toList(),
    };

    RequestResult result = await HttpRequest.instance.post('$basePath/submit',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
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
  Future<bool> submitReview(int id, int submissionId, List<Review> reviews) async {

    RequestResult result = await HttpRequest.instance.put('$basePath/$id/submissions/$submissionId/reviews',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      data: reviews.map((e) => e.toMap()).toList(),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Test-submitReview] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Test-submitReview] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<bool> delete(int id) async {
    RequestResult result = await HttpRequest.instance.delete('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
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
  Future<TestInfo?> getInfo(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/info',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
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

  @override
  Future<bool> checkTestPassword(int id, String password) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/check-password',
        options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
        queryParameters: {
          'password': password,
        }
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-checkTestPassword] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (result.statusCode != 200) {
      debugPrint('Api Error: [Course-checkTestPassword] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

}