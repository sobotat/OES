
import 'package:oes/src/objects/ApiObject.dart';

class Achievement extends ApiObject {

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.unlocked,
  });

  String id;
  String name;
  String description;
  bool unlocked;

  // id = login_10x
  // name= I see you there for many times
  // description= Login 10 times

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        unlocked: json['unlocked']
    );
  }
}