
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/courseItems/QuizGateway.dart';

class ApiQuizGateway extends QuizGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/quizzes';

  @override
  Future<Quiz?> get(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Quiz-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Quiz-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Quiz.fromJson(result.data);
  }

  @override
  Future<Quiz?> create(int courseId, Quiz quiz) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<Quiz?> update(Quiz quiz) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

}