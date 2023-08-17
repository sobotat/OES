import 'package:flutter/material.dart';
import 'package:oes/src/RestApi/DatabaseObject.dart';

class Course extends ObjectDO {

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