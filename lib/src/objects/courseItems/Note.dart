
import 'package:oes/src/objects/courseItems/CourseItem.dart';

class Note extends CourseItem {

  Note({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required this.data,
  }) : super(type: 'note');

  String data;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'data': data,
      });
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      name: json['name'],
      created: DateTime.tryParse(json['created'])!,
      createdById: json['createdById'],
      isVisible: json['isVisible'],
      data: json['data'],
    );
  }
}