
import 'package:flutter/material.dart';
import 'package:oes/Src/Objects/User.dart';
import 'package:oes/src/Objects/Course.dart';
import 'package:oes/src/RestApi/CourseGateway.dart';
import 'package:oes/src/RestApi/UserGateway.dart';

class CourseGatewayTemp implements CourseGateway {

  late Map<User, List<Course>> data;

  CourseGatewayTemp() {
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
        Course(id: 31, name: 'Python', shortName: 'P'),
        Course(id: 52, name: 'English', shortName: 'E', color: Colors.deepOrange),
        Course(id: 673, name: 'Java', shortName: 'J', color: Colors.green),
        Course(id: 1234, name: 'C#', shortName: 'C#'),
        Course(id: 225, name: 'Math', shortName: 'M', color: Colors.blue[900]),
      ];
    });
  }

  @override
  Future<List<Course>> getUserCourses(User user) {
    return Future.delayed(const Duration(seconds: 1), () {
      var out = data[user];
      return data[user] ?? [];
    });
  }

}