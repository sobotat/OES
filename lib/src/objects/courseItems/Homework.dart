
import 'package:oes/src/objects/courseItems/SchedulableItem.dart';

class Homework extends SchedulableItem {

  Homework({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required super.scheduled,
    required super.end,
    required this.task,
  }) : super(type: 'homework');

  String task;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'task': task,
      });
  }

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'],
      name: json['name'],
      created: DateTime.tryParse(json['created'])!,
      createdById: json['createdById'],
      isVisible: json['isVisible'],
      scheduled: DateTime.tryParse(json['scheduled'])!,
      end: DateTime.tryParse(json['end'])!,
      task: json['task'],
    );
  }
}