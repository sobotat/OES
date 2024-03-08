
import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Note.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/courseItems/NoteGateway.dart';
import 'package:oes/config/AppApi.dart';

class ApiNoteGateway extends NoteGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/notes';

  @override
  Future<Note?> get(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Note-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Note-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Note.fromJson(result.data);
  }

  @override
  Future<Note?> create(int courseId, Note note) async {
    note.created = DateTime.now();
    Map<String, dynamic> data = note.toMap();
    data.remove('id');
    data.remove('type');
    print(basePath.toString());

    RequestResult result = await HttpRequest.instance.post(basePath,
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      queryParameters: {
        'courseId':courseId,
      },
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Note-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Note-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Note.fromJson(result.data);
  }

  @override
  Future<Note?> update(Note note) async {
    Map<String, dynamic> data = note.toMap();
    data.remove('id');

    RequestResult result = await HttpRequest.instance.put('$basePath/${note.id}',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Note-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Note-update] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return get(note.id);
  }

  @override
  Future<bool> delete(int id) async {
    RequestResult result = await HttpRequest.instance.delete('$basePath/$id',
      options: AuthHttpRequestOptions(token: AppSecurity.instance.user!.token),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Note-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Note-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

}