
import 'package:oes/src/objects/courseItems/ExamItem.dart';

class Test extends ExamItem {

  Test({
    required super.id,
    required super.name,
    required super.created,
    required super.createdBy,
    required super.scheduled,
    required super.end,
    required super.duration,
    required this.password,
  });

  String password;
}