import 'package:flutter/material.dart';
import 'package:oes/src/restApi/DatabaseObject.dart';

class Course extends DatabaseObject {

  Course({
    required id,
    required this.name,
    required this.shortName,
    this.color,
  }) : super(id: id);

  String name;
  String shortName;
  Color? color;
}