import 'package:flutter/material.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/OtherUser.dart';
import 'package:oes/src/restApi/ApiObject.dart';
import 'package:oes/src/restApi/CourseGateway.dart';

class Course extends ApiObject {

  Course({
    required id,
    required this.name,
    required this.shortName,
    required this.description,
    this.color,
  }) : super(id: id);

  String name;
  String shortName;
  String description;
  Color? color;
  List<CourseItem>? _items;
  List<OtherUser>? _teachers;

  Future<List<CourseItem>> get items async {
    if (_items != null) return _items!;
    _items = await CourseGateway.instance.getCourseItems(id);
    return _items!;
  }

  Future<List<OtherUser>> get teachers async {
    if (_teachers != null) return _teachers!;
    _teachers = await CourseGateway.instance.getCourseTeachers(id);
    return _teachers!;
  }
}