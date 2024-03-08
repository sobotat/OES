
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
    required this.text,
    required this.fileName,
  }) : super(type: 'homework');

  String task;
  String text;
  String? fileName;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'task': task,
        'text': text,
        'fileName': fileName,
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
      text: json['text'] ?? "",
      fileName: json['fileName'],
    );
  }
}