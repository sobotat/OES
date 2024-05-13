
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/SharePermission.dart';
import 'package:oes/src/objects/ShareUser.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/UserQuizGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/UserQuizShareGateway.dart';

class ApiUserQuizShareGateway extends UserQuizShareGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/userQuizzes';

  @override
  Future<SharePermission> getPermission(int itemId, int userId) async {
    UserQuiz? userQuiz = await UserQuizGateway.instance.get(itemId);
    if(userQuiz!.createdById == userId) return SharePermission.editor;

    List<ShareUser> users = await getAll(itemId);
    return users.where((element) => element.id == userId).first.permission;
  }

  @override
  Future<List<ShareUser>> getAll(int itemId) async {
    RequestResult result = await HttpRequest.instance.get("$basePath/$itemId/permissions",
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [UserQuizShareGateway-getAll] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (!result.checkOk() || result.data is! List<dynamic>) {
      debugPrint('Api Error: [UserQuizShareGateway-getAll] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<ShareUser> out = [];
    for(Map<String,dynamic> json in result.data) {
      try {
        out.add(ShareUser.fromJson(json));
      } catch (e, s) {
        print(e);
        debugPrint(s.toString());
      }
    }

    out.sort((a, b) {
      if(a.permission == SharePermission.editor && b.permission == SharePermission.editor) {
        return a.lastName.compareTo(b.lastName);
      } else if (a.permission == SharePermission.editor && b.permission == SharePermission.viewer) {
        return -1; // Editor comes before Viewer
      } else if (a.permission == SharePermission.viewer && b.permission == SharePermission.editor) {
        return 1;  // Viewer comes after Editor
      }
      return 0;
    },);

    return out;
  }

  @override
  Future<bool> add(int itemId, ShareUser user) async {
    RequestResult result = await HttpRequest.instance.post("$basePath/$itemId/permissions",
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      data: {
        "userId": user.id,
        "permission": user.permission.index,
      },
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [UserQuizShareGateway-add] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [UserQuizShareGateway-add] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<bool> remove(int itemId, int userId) async {
      RequestResult result = await HttpRequest.instance.delete("$basePath/$itemId/permissions/$userId",
          options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      );

      if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [UserQuizShareGateway-remove] ${result.statusCode} -> ${result.message}');
      return false;
      }

      if (!result.checkOk()) {
      debugPrint('Api Error: [UserQuizShareGateway-remove] ${result.statusCode} -> ${result.message}');
      return false;
      }

      return true;
  }

  @override
  Future<bool> update(int itemId, ShareUser user) async {
    RequestResult result = await HttpRequest.instance.put("$basePath/$itemId/permissions",
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      data: {
        "userId": user.id,
        "permission": user.permission.index,
      },
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [UserQuizShareGateway-update] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [UserQuizShareGateway-update] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

}