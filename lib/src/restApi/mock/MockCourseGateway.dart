import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/CourseItem.dart';
import 'package:oes/src/objects/OtherUser.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/CourseGateway.dart';

class MockCourseGateway implements CourseGateway {

  static final MockCourseGateway instance = MockCourseGateway._();
  late Map<SignedUser, List<Course>> data;

  MockCourseGateway._() {
    data = <SignedUser, List<Course>> {};

    var user = SignedUser(
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
        Course(id: 1234, name: 'C#', shortName: 'C#', description: 'You will learn basic skill about c#. '
            '\nLong description ........................................................................................'
            '\n..............'
            '\n............................................................................'
            '\nsssssssssssssssss'),
        Course(id: 225, name: 'Math', shortName: 'M', description: '', color: Colors.blue[900]),
      ];
    });
  }

  @override
  Future<List<Course>> getUserCourses(SignedUser user) {
    return Future.delayed(const Duration(seconds: 1), () {
      return data[user] ?? [];
    });
  }

  @override
  Future<Course?> getCourse(int id) {
    return Future.delayed(const Duration(seconds: 1), () {
      SignedUser? user = AppSecurity.instance.user;
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
        Homework(
          id: 1,
          name: 'Write 100x Hello',
        ),
        Quiz(
          id: 2,
          name: 'Learn Cities',
        ),
        Test(
          id: 3,
          name: 'Test Cities'
        ),
      ];
    },);
  }

  @override
  Future<List<OtherUser>> getCourseTeachers(int id) {
    List<OtherUser> users = [
      OtherUser(firstName: 'Karel', lastName: 'New'),
      OtherUser(firstName: 'Mark', lastName: 'Test'),
      OtherUser(firstName: 'Jane', lastName: 'Doe'),
      OtherUser(firstName: 'John', lastName: 'Doe'),
    ];

    return Future.delayed(const Duration(seconds: 1), () {
      List<int> used = [];
      List<OtherUser> out = [];
        for(int i = 0; i < Random().nextInt(users.length); i++) {
          while(true) {
            int index = Random().nextInt(users.length);
            if(used.contains(index)) continue;
            used.add(index);
            out.add(users[index]);
            break;
          }
        }
      return out;
    },);
  }

}