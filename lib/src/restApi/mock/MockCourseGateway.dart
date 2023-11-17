import 'dart:html';
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
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';

class MockCourseGateway implements CourseGateway {

  late Map<User, List<Course>> data;
  List<CourseItem> items = [
    Homework(
      id: 1,
      name: 'Write 100x Hello',
      created: DateTime(2022, 12, 1, 15, 35),
      createdById: 1,
      isVisible: true,
      end: DateTime(2023, 12, 31, 23, 59),
      scheduled: DateTime(2023, 1, 1, 0, 0),
    ),
    Quiz(
      id: 2,
      name: 'Learn Cities',
      created: DateTime(2022, 12, 1, 15, 35),
      createdById: 2,
      isVisible: true,
      end: DateTime(2023, 12, 31, 23, 59),
      scheduled: DateTime(2023, 1, 1, 0, 0),
      duration: 162000,
      questions: [],
    ),
    Test(
      id: 3,
      name: 'Test Cities',
      created: DateTime(2022, 12, 1, 15, 35),
      createdById: 2,
      isVisible: true,
      end: DateTime(2023, 12, 31, 23, 59),
      scheduled: DateTime(2023, 1, 1, 0, 0),
      duration: 162000,
      maxAttempts: 1,
      questions: [],
    ),
    Test(
      id: 4,
      name: 'Free Points',
      created: DateTime(2022, 12, 1, 15, 35),
      createdById: 3,
      isVisible: true,
      end: DateTime(2023, 12, 31, 23, 59),
      scheduled: DateTime(2023, 1, 1, 0, 0),
      duration: 162000,
      maxAttempts: 3,
      questions: [],
    ),
  ];

  MockCourseGateway() {
    data = <User, List<Course>> {};

    UserGateway.instance.getAllUsers(1).then((value) {
      for(User user in value!.data) {
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
    });
  }

  @override
  Future<List<Course>> getUserCourses(SignedUser user) {
    return Future.delayed(const Duration(seconds: 2), () async {
      if (data.isEmpty) await Future.delayed(const Duration(seconds: 1));
      List<Course> out = [];
      data.forEach((key, value) {
        if (key.id == user.id) {
          out = value;
        }
      });
      return out;
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
      User(id: 10, firstName: 'Karel', lastName: 'New', username: 'karel.new', role: UserRole.teacher),
      User(id: 20, firstName: 'Mark', lastName: 'Test', username: 'mark.test', role: UserRole.teacher),
      User(id: 30, firstName: 'Jane', lastName: 'Doe', username: 'jane.doe', role: UserRole.admin),
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
  Future<List<User>> getCourseStudents(int id) async {
    List<User> users = [
      User(id: 12, firstName: 'Karel', lastName: 'Student', username: 'karel.student', role: UserRole.student),
      User(id: 23, firstName: 'Mark', lastName: 'Student', username: 'mark.student', role: UserRole.student),
      User(id: 34, firstName: 'Jane', lastName: 'Student', username: 'jane.student', role: UserRole.student),
    ];
    return users;
  }

  @override
  Future<List<UserQuiz>> getUserQuizzes(SignedUser user) {
    return Future.delayed(const Duration(seconds: 1), () => [
      UserQuiz(
        id: 1,
        name: 'Some User Created Quiz',
        created: DateTime(2022, 12, 1, 15, 35),
        createdById: 1,
        isVisible: true,
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
          createdById: 1,
          isVisible: true,
          questions: []
      ),
    );
  }

  @override
  Future<bool> checkTestPassword(int courseId, int itemId, String password) async {
    return '1234' == password;
  }

  @override
  Future<bool> updateCourse(Course course) async {
    for (User user in data.keys) {
       List<Course>? courses = data[user];
       if (courses == null) continue;
       courses[courses.indexWhere((element) => element.id == course.id)] = course;
       data[user] = courses;
    }
    return true;
  }

  @override
  Future<Course?> createCourse(Course course) async {
    course.id = Random.secure().nextInt(1000) + 1000;
    for (User user in data.keys) {
      List<Course>? courses = data[user];
      if (courses == null) continue;
      courses[courses.indexWhere((element) => element.id == course.id)] = course;
      data[user] = courses;
    }
    return course;
  }

  @override
  Future<bool> deleteCourse(Course course) async {
    for (User user in data.keys) {
      List<Course>? courses = data[user];
      if (courses == null) continue;
      courses.removeAt(courses.indexWhere((element) => element.id == course.id));
      data[user] = courses;
    }
    return true;
  }

  @override
  void clearIdentityMap() {}

}