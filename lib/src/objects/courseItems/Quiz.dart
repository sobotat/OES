
import 'package:oes/src/objects/courseItems/SchedulableItem.dart';

class Quiz extends SchedulableItem {

  Quiz({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required super.scheduled,
    required super.end,
  }) : super(type: 'quiz');

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
        id: json['id'],
        name: json['name'],
        created: DateTime.tryParse(json['created'])!,
        createdById: json['createdById'],
        isVisible: json['isVisible'],
        scheduled: DateTime.tryParse(json['scheduled'])!,
        end: DateTime.tryParse(json['end'])!,
    );
  }
}