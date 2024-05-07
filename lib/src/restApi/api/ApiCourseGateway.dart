
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
  Map<int, Course> map = {};

  @override
  Future<Course?> getCourse(int id) async {

    // Identity Map
    Course? course = map[id];
    if (course != null) return course;

    RequestResult result = await HttpRequest.instance.get('$basePath/$id',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getUserCourses] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (result.statusCode != 200 || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Course-getUserCourses] ${result.statusCode} -> ${result.message}');
      return null;
    }

    course = Course.fromJson(result.data);
    map[id] = course;

    return course;
  }

  @override
  Future<List<CourseItem>> getCourseItems(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/items',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getCourseItems] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (result.statusCode != 200 || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Course-getCourseItems] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<CourseItem> items = [];
    for (Map<String, dynamic> json in result.data) {
      try {
        items.add(CourseItem.fromJson(json));
      } on Exception catch (e) {
        debugPrint('Api Error: [Course-getCourseItems] $e');
      }
    }

    return items;
  }

  @override
  Future<List<User>> getCourseTeachers(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/users',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
        queryParameters: {
          'courseId': id,
          'userCourseRoles': [0],
        }
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getCourseTeachers] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (result.statusCode != 200 || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Course-getCourseTeachers] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<User> users = [];
    for (Map<String, dynamic> json in result.data) {
      try {
        users.add(User.fromJson(json));
      } on Exception catch (e) {
        debugPrint('Api Error: [Course-getCourseTeachers] $e');
      }
    }

    return users;
  }

  @override
  Future<List<User>> getCourseStudents(int id) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$id/users',
        options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
        queryParameters: {
          'courseId': id,
          'userCourseRoles': [1],
        }
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-getCourseStudents] ${result.statusCode} -> ${result.message}');
      return [];
    }

    if (result.statusCode != 200 || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Course-getCourseStudents] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<User> users = [];
    for (Map<String, dynamic> json in result.data) {
      try {
        users.add(User.fromJson(json));
      } on Exception catch (e) {
        debugPrint('Api Error: [Course-getCourseStudents] $e');
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

    //TODO: Add support for paged data

    List<Course> courses = [];
    for (Map<String, dynamic> json in result.data['items']) {
      try {
        Course course = Course.fromJson(json);
        courses.add(course);
        map[course.id] = course;
      } on Exception catch (e) {
        debugPrint('Api Error: [Course-getUserCourses] $e');
      }
    }

    return courses;
  }

  @override
  Future<bool> updateCourse(Course course) async {

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
      debugPrint('Api Error: [Course-updateCourse] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Course-updateCourse] ${result.statusCode} -> ${result.message}');
      return false;
    }

    map[course.id] = course;
    return true;
  }

  @override
  Future<Course?> createCourse(Course course) async {

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
      debugPrint('Api Error: [Course-createCourse] ${result.statusCode} -> ${result.message}');
      return null;
    }

    if (!result.checkOk() || result.data is! Map<String, dynamic>) {
      debugPrint('Api Error: [Course-createCourse] ${result.statusCode} -> ${result.message}');
      return null;
    }

    course = Course.fromJson(result.data);
    map[course.id] = course;

    return course;
  }

  @override
  Future<bool> deleteCourse(Course course) async {
    RequestResult result = await HttpRequest.instance.delete('$basePath/${course.id}',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-deleteCourse] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      debugPrint('Api Error: [Course-deleteCourse] ${result.statusCode} -> ${result.message}');
      return false;
    }

    return true;
  }

  @override
  void clearIdentityMap() {
    map.clear();
  }

  @override
  Future<bool> joinCourse(String code) async {

    RequestResult result = await HttpRequest.instance.put('$basePath/$code/join',
      options: AuthHttpRequestOptions(token: await AppSecurity.instance.getToken()),
    );

    if (result.checkUnauthorized()) {
      AppSecurity.instance.logout();
      debugPrint('Api Error: [Course-joinCourse] ${result.statusCode} -> ${result.message}');
      return false;
    }

    if (!result.checkOk()) {
      if (result.statusCode == 404) {
        return false;
      }

      debugPrint('Api Error: [Course-joinCourse] ${result.statusCode} -> ${result.message}');
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