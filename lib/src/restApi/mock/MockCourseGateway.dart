import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/CourseGateway.dart';

class MockCourseGateway implements CourseGateway {

  static final MockCourseGateway instance = MockCourseGateway._();
  late Map<User, List<Course>> data;

  MockCourseGateway._() {
    data = <User, List<Course>> {};

    var user = User(
        id: 1,
        firstName:'Karel',
        lastName:'Novak',
        username:'admin',
        token: '123456789'
    );

    data.putIfAbsent(user, () {
      return [
        Course(id: 31, name: 'Python', shortName: 'P', description: 'You will learn basic skill about python'),
        Course(id: 52, name: 'English', shortName: 'E', description: 'You will learn basic skill about english', color: Colors.deepOrange),
        Course(id: 673, name: 'Java', shortName: 'J', description: 'You will learn basic skill about java', color: Colors.green),
        Course(id: 1234, name: 'C#', shortName: 'C#', description: 'You will learn basic skill about c#. Long description ...................ss sd ds sd a ds as asd  asd s d sdds  ds ds dsd d sdsads............................ sssssssssssssssss'),
        Course(id: 225, name: 'Math', shortName: 'M', description: '', color: Colors.blue[900]),
      ];
    });
  }

  @override
  Future<List<Course>> getUserCourses(User user) {
    return Future.delayed(const Duration(seconds: 1), () {
      return data[user] ?? [];
    });
  }

  @override
  Future<Course?> getCourse(int id) {
    return Future.delayed(const Duration(seconds: 1), () {
      User? user = AppSecurity.instance.user;
      if (user == null) return null;
      if (data[user] == null) return null;

      for (Course course in data[user] ?? []){
        if(course.id == id) return course;
      }
     return null;
    });
  }

  @override
  Future<List<CourseItem>> getCourseItems(int id) {
    return Future.delayed(const Duration(seconds: 1), () {
      return [
        Homework(id: 1),
        Quiz(id: 2),
        Test(id: 3),
      ];
    },);
  }

}