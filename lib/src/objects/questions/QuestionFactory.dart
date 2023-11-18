
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';

class QuestionFactory {

  static Question? fromJson(Map<String, dynamic> json) {

    String type = json["type"].toString().toLowerCase();
    switch(type) {
      case "open": return OpenQuestion.fromJson(json);
      case "pick-one": return PickOneQuestion.fromJson(json);
      case "pick-many": return PickManyQuestion.fromJson(json);
      default:
        print('Type of Question [$type] is not Supported');
        break;
    }

    return null;
  }
}