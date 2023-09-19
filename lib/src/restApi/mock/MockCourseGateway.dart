import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/CourseGateway.dart';

class MockCourseGateway implements CourseGateway {

  late Map<SignedUser, List<Course>> data;
  List<CourseItem> items = [
    Homework(
      id: 1,
      name: 'Write 100x Hello',
      created: DateTime(2022, 12, 1, 15, 35),
      createdBy: User(id: 3, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe'),
      end: DateTime(2023, 12, 31, 23, 59),
      scheduled: DateTime(2023, 1, 1, 0, 0),
    ),
    Quiz(
      id: 2,
      name: 'Learn Cities',
      created: DateTime(2022, 12, 1, 15, 35),
      createdBy: User(id: 3, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe'),
      end: DateTime(2023, 12, 31, 23, 59),
      scheduled: DateTime(2023, 1, 1, 0, 0),
      duration: 162000,
    ),
    Test(
      id: 3,
      name: 'Test Cities',
      created: DateTime(2022, 12, 1, 15, 35),
      createdBy: User(id: 3, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe'),
      end: DateTime(2023, 12, 31, 23, 59),
      scheduled: DateTime(2023, 1, 1, 0, 0),
      duration: 162000,
      password: '1234',
    ),
    Test(
      id: 4,
      name: 'Free Points',
      created: DateTime(2022, 12, 1, 15, 35),
      createdBy: User(id: 3, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe'),
      end: DateTime(2023, 12, 31, 23, 59),
      scheduled: DateTime(2023, 1, 1, 0, 0),
      duration: 162000,
      password: '',
    ),
  ];

  MockCourseGateway() {
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
            '\n.......................................................................................'
            '\n............................................................................'
            '\n...............................................................'
            '\n..................................................'),
        Course(id: 225, name: 'Math', shortName: 'M', description: '', color: Colors.blue[900]),
      ];
    });
  }

  @override
  Future<List<Course>> getUserCourses(SignedUser user) {
    return Future.delayed(const Duration(seconds: 2), () {
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
      return items;
    },);
  }

  @override
  Future<List<User>> getCourseTeachers(int id) {
    List<User> users = [
      User(id: 1, firstName: 'Karel', lastName: 'New', username: 'karel.new'),
      User(id: 2, firstName: 'Mark', lastName: 'Test', username: 'mark.test'),
      User(id: 3, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe'),
    ];

    return Future.delayed(const Duration(seconds: 1), () {
      List<int> used = [];
      List<User> out = [];
        for(int i = 0; i < Random().nextInt(users.length - 1) + 1; i++) {
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

  @override
  Future<List<UserQuiz>> getUserQuizzes(SignedUser user) {
    return Future.delayed(const Duration(seconds: 1), () => [
      UserQuiz(
        id: 1,
        name: 'Some User Created Quiz',
        created: DateTime(2022, 12, 1, 15, 35),
        createdBy: User(id: 3, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe'),
        questions: []
      ),
    ]);
  }

  @override
  Future<UserQuiz> getUserQuiz(SignedUser user, int courseId, int itemId) {
    return Future.delayed(const Duration(seconds: 1), () =>
      UserQuiz(
          id: 1,
          name: 'Some User Created Quiz',
          created: DateTime(2022, 12, 1, 15, 35),
          createdBy: User(id: 3, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe'),
          questions: []
      ),
    );
  }

  @override
  Future<CourseItem?> getCourseItem(int courseId, int itemId) {
    return Future.delayed(const Duration(seconds: 1), () {
      for (CourseItem item in items) {
        if (item.id == itemId) return item;
      }
      return null;
    });
  }

}