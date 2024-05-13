
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';

class ApiCourseGateway implements CourseGateway {

  String basePath = '${AppApi.instance.apiServerUrl}/api/courses';

  @override
  Future<Course?> get(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Course-get] ${result.statusCode} -> ${result.message}');
      return null;
    }
    
    return Course.fromJson(result.data);
  }

  @override
  Future<List<CourseItem>> getItems(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/items',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getItems] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (!result.checkOk() || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Course-getItems] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<CourseItem> items = [];
    for (Map<String, dynamic> json in result.data) {
      try {
        items.add(CourseItem.fromJson(json));
      } on Exception catch (e) {
        debugPrint('Api Error: [Course-getItems] $e');
      }
    }

    return items;
  }

  @override
  Future<List<User>> getTeachers(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/users',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
        queryParameters: {
          'courseId': id,
          'userCourseRoles': [0],
        }
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getTeachers] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (result.statusCode != 200 || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Course-getTeachers] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<User> users = [];
    for (Map<String, dynamic> json in result.data) {
      try {
        users.add(User.fromJson(json));
      } on Exception catch (e) {
        debugPrint('Api Error: [Course-getTeachers] $e');
      }
    }

    return users;
  }

  @override
  Future<List<User>> getStudents(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/users',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
        queryParameters: {
          'courseId': id,
          'userCourseRoles': [1],
        }
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getStudents] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (result.statusCode != 200 || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Course-getStudents] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<User> users = [];
    for (Map<String, dynamic> json in result.data) {
      try {
        users.add(User.fromJson(json));
      } on Exception catch (e) {
        debugPrint('Api Error: [Course-getStudents] $e');
      }
    }

    return users;
  }

  @override
  Future<List<User>> getUsers(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/users',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      queryParameters: {
        'courseId': id,
        'userCourseRoles': [0,1],
      }
    );

    if (result.checkUnauthorized()) {
    AppSecurity.instance.logout();
    debugPrint('Api Error: [Course-getUsers] ${result.statusCode} -> ${result.message}');
    return [];
    }

    if (result.statusCode != 200 || result.data is! List<dynamic>) {
    debugPrint('Api Error: [Course-getUsers] ${result.statusCode} -> ${result.message}');
    return [];
    }

    List<User> users = [];
    for (Map<String, dynamic> json in result.data) {
    try {
    users.add(User.fromJson(json));
    } on Exception catch (e) {
    debugPrint('Api Error: [Course-getUsers] $e');
    }
    }

    return users;
  }

  @override
  Future<List<Course>> getUserCourses(User user) async {

    RequestResult result = await HttpRequest.instance.get(basePath,
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      queryParameters: {
        'userId': user.id,
        'pageSize': 1024
      }
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getUserCourses] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Course-getUserCourses] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<Course> courses = [];
    for (Map<String, dynamic> json in result.data['items']) {
      try {
        Course course = Course.fromJson(json);
        courses.add(course);
      } on Exception catch (e) {
        debugPrint('Api Error: [Course-getUserCourses] $e');
      }
    }

    return courses;
  }

  @override
  Future<bool> update(Course course) async {

    List<int> teachers = [];
    for (User user in await course.teachers) {
      teachers.add(user.id);
    }

    List<int> students = [];
    for (User user in await course.students) {
      students.add(user.id);
    }

    Map<String, dynamic> data = course.toMap();
    data.remove('id');
    data.addAll({
      'teacherIds': teachers,
    });
    data.addAll({
      'attendantIds': students,
    });

    RequestResult result = await HttpRequest.instance.put('$basePath/${course.id}',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-update] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Course-update] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<Course?> create(Course course) async {

    Map<String, dynamic> data = course.toMap()
      ..remove('id')
      ..addAll({'teacherIds' : [ AppSecurity.instance.user!.id ]})
      ..addAll({'attendantIds': []});

    RequestResult result = await HttpRequest.instance.post(basePath,
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
      data: data,
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Course-create] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Course.fromJson(result.data);
  }

  @override
  Future<bool> delete(Course course) async {
    RequestResult result = await HttpRequest.instance.delete('$basePath/${course.id}',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Course-delete] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<bool> join(String code) async {

    RequestResult result = await HttpRequest.instance.put('$basePath/$code/join',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-join] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      if (result.statusCode == 404) {
        return false;
      }

      debugPrint('Api Error: [Course-join] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  Future<String?> generateCode(Course course) async {

    RequestResult result = await HttpRequest.instance.put('$basePath/${course.id}/code',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-generateCode] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! String) {
      debugPrint('Api Error: [Course-generateCode] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return result.data;
  }

  @override
  Future<String?> getCode(Course course) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/${course.id}/code',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getCode] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! String) {
      debugPrint('Api Error: [Course-getCode] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return result.data;
  }
}