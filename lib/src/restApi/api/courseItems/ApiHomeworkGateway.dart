
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/courseItems/HomeworkGateway.dart';

class ApiHomeworkGateway implements HomeworkGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/homeworks';

  @override
  Future<bool> submit(String text, MultipartFile? file, { Function(double progress)? onProgress }) async {

    FormData formData = FormData.fromMap({
      "text": text,
      "file": file,
    });

    RequestResult result = await HttpRequest.instance.post(basePath,
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