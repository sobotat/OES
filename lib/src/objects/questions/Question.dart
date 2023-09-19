
import 'package:oes/src/objects/ApiObject.dart';

abstract class Question extends ApiObject {

  Question({
    required super.id,
    required this.title,
    required this.description,
    required this.points,
  });

  String title;
  String description;
  int points;

}