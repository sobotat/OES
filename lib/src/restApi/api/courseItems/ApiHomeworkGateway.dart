
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/courseItems/HomeworkGateway.dart';

class ApiHomeworkGateway implements HomeworkGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/homeworks';
  String userBasePath = '${AppApi.instance.apiServerUrl}/api/users';

  @override
  Future<Homework?> get(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Homework-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Homework.fromJson(result.data);
  }

  @override
  Future<List<HomeworkSubmission>> getSubmission(int id) async {
    if (AppSecurity.instance.user == null) return [];
    return await getUserSubmission(id, AppSecurity.instance.user!.id);
  }

  @override
  Future<List<HomeworkSubmission>> getUserSubmission(int id, int userId) async {
    RequestResult result = await HttpRequest.instance.get('$userBasePath/$userId/homework-submissions',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        "homeworkId": id,
      }
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-getSubmission] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (!result.checkOk() || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Homework-getSubmission] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<HomeworkSubmission> out = [];
    for (Map<String, dynamic> json in result.data) {
      out.add(HomeworkSubmission.fromJson(json));
    }
    return out;
  }

  @override
  Future<List<int>?> getAttachment(int attachmentId, { Function(double progress)? onProgress }) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/attachments/$attachmentId',
      options: AuthHttpRequestOptions(
        token: AppSecurity.instance.user!.token,
        responseType: HttpResponseType.bytes
      ),
      onReceiveProgress: onProgress
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-getAttachment] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Homework-getAttachment] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return result.data as List<int>;
  }

  @override
  Future<Homework?> create(int courseId, Homework homework) async {
    Map<String, dynamic> data = homework.toMap();
    data.remove('id');
    data.remove('type');

    RequestResult result = await HttpRequest.instance.post(basePath,
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        'courseId':courseId,
      },
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Homework-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Homework.fromJson(result.data);
  }

  @override
  Future<Homework?> update(Homework homework) async {
    Map<String, dynamic> data = homework.toMap();
    data.remove('id');

    RequestResult result = await HttpRequest.instance.put('$basePath/${homework.id}',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Homework-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return get(homework.id);
  }

  @override
  Future<bool> delete(int id) async {
    RequestResult result = await HttpRequest.instance.delete('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Homework-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<bool> submit(int id, String text, List<MultipartFile> files, { Function(double progress)? onProgress }) async {

    FormData formData = FormData.fromMap({
      "Text": text,
      "FormFiles": files,
    });

    RequestResult result = await HttpRequest.instance.post("$basePath/$id/submissions",
      options: AuthHttpRequestOptions(
        token: AppSecurity.instance.user!.token,
        contentType: "multipart/form-data",
        sendTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1)
      ),
      onSendProgress: onProgress,
      data: formData,
    ).onError((error, stackTrace) {
      throw error!;
    });

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-submit] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Homework-submit] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<bool> submitReviewText(int id, int submitId, String text) async {
    RequestResult result = await HttpRequest.instance.patch("$basePath/$id/submissions/$submitId",
      options: AuthHttpRequestOptions(
          token: AppSecurity.instance.user!.token,
      ),
      data: "\"$text\""
    ).onError((error, stackTrace) {
      throw error!;
    });

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-submitReviewText] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Homework-submitReviewText] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<int?> getScore(int id, int userId) async {
    RequestResult result = await HttpRequest.instance.get("$userBasePath/$userId/homework-scores/$id",
        options: AuthHttpRequestOptions(
          token: AppSecurity.instance.user!.token,
        ),
    ).onError((error, stackTrace) {
      throw error!;
    });

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-getScore] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Homework-getScore] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return result.data;
  }

  @override
  Future<bool> submitScore(int id, int userId, int points) async {
    RequestResult result = await HttpRequest.instance.put("$userBasePath/$userId/homework-scores/$id",
        options: AuthHttpRequestOptions(
          token: AppSecurity.instance.user!.token,
        ),
        data: points.toString()
    ).onError((error, stackTrace) {
      throw error!;
    });

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Homework-submitScore] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Homework-submitScore] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

}