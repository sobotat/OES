import 'package:flutter/material.dart';
import 'package:oes/src/objects/CourseItem.dart';
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

  Future<List<CourseItem>> get items async {
    if (_items != null) return _items!;
    _items = await CourseGateway.gateway.getCourseItems(id);
    return _items!;
  }
}