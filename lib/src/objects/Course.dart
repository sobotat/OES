import 'package:flutter/material.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/ApiObject.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';

class Course extends ApiObject {

  Course({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    this.color,
  });

  int id;
  String name;
  String shortName;
  String description;
  Color? color;
  List<User>? _teachers;
  List<User>? _students;

  void setTeachers(List<User> value) {
    _teachers = value;
  }

  Future<List<User>> get teachers async {
    if (_teachers != null) return _teachers!;
    _teachers = await CourseGateway.instance.getTeachers(id);
    return _teachers!;
  }

  void setStudents(List<User> value) {
    _students = value;
  }

  Future<List<User>> get students async {
    if (_students != null) return _students!;
    _students = await CourseGateway.instance.getStudents(id);
    return _students!;
  }

  Future<bool> isTeacherInCourse(User user) async {
    for(User teacher in await teachers) {
      if (user.id == teacher.id) {
        return true;
      }
    }
    return false;
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'id': id,
        'name': name,
        'shortName': shortName,
        'description': description,
        'color': color != null ? '0x${color!.toString().split('0x')[1].split(')')[0]}' : null
      });
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      shortName: json['shortName'],
      description: json['description'],
      color: json['color'] != null ? Color(int.parse(json['color'])) : null,
    );
  }
}