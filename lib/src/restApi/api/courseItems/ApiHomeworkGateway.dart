
import 'package:dio/dio.dart';
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
      "HomeworkId": id,
      "Text": text,
      "FormFiles": files,
    });

    RequestResult result = await HttpRequest.instance.post("$basePath/submit",
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token,
        headers: {
          'Content-Type': 'multipart/form-data'
        },
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

}