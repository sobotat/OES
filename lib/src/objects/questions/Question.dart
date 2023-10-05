
import 'package:oes/src/objects/ApiObject.dart';

abstract class Question extends ApiObject {

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
  });

  int id;
  String title;
  String description;
  int points;

}