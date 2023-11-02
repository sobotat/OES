
import 'package:oes/src/objects/ApiObject.dart';

abstract class Question extends ApiObject {

  Question({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.points,
  });

  int id;
  String type;
  String title;
  String description;
  int points;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'points': points
    };
  }
}