
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/courseItems/UserQuizGateway.dart';

class ApiUserQuizGateway extends UserQuizGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/userQuizzes';

  @override
  Future<UserQuiz?> get(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [UserQuiz-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [UserQuiz-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return UserQuiz.fromJson(result.data);
  }

  @override
  Future<UserQuiz?> create(int courseId, UserQuiz quiz) async {
    quiz.created = DateTime.now();
    Map<String, dynamic> data = quiz.toMap();
    data.remove('id');
    data.remove('type');
    for (Map<String, dynamic> question in data['questions']) {
      question.remove('id');
      for(Map<String, dynamic> option in question['options']) {
        option.remove('id');
      }
    }

    RequestResult result = await HttpRequest.instance.post(basePath,
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      queryParameters: {
        'courseId':courseId,
      },
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [UserQuiz-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [UserQuiz-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return UserQuiz.fromJson(result.data);
  }

  @override
  Future<UserQuiz?> update(UserQuiz quiz) async {
    Map<String, dynamic> data = quiz.toMap();
    data.remove('id');
    data.remove('type');
    for (Map<String, dynamic> question in data['questions']) {
      question.remove('id');
      for(Map<String, dynamic> option in question['options']) {
        option.remove('id');
      }
    }

    RequestResult result = await HttpRequest.instance.put('$basePath/${quiz.id}',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [UserQuiz-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [UserQuiz-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return get(quiz.id);
  }

  @override
  Future<bool> delete(int id) async {
    RequestResult result = await HttpRequest.instance.delete('$basePath/$id',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [UserQuiz-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [UserQuiz-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

}