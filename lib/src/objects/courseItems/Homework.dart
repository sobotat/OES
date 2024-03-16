
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

class HomeworkSubmission {

  HomeworkSubmission({
    required this.id,
    required this.text,
    required this.attachments
  });

  int id;
  String? text;
  List<HomeworkSubmissionAttachment> attachments;


  @override
  String toString() {
    return '{id: $id, text: $text, fileNames: $attachments}';
  }

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) {
    List<HomeworkSubmissionAttachment> files = [];
    for(Map<String, dynamic> fileJson in json['attachments']) {
      files.add(HomeworkSubmissionAttachment.fromJson(fileJson));
    }
    return HomeworkSubmission(
      id: json['id'],
      text: json['text'],
      attachments: files,
    );
  }
}

class HomeworkSubmissionAttachment {

  HomeworkSubmissionAttachment({
    required this.id,
    required this.fileName,
  });

  int id;
  String fileName;


  @override
  String toString() {
    return '{id: $id, fileName: $fileName}';
  }

  factory HomeworkSubmissionAttachment.fromJson(Map<String, dynamic> json) {
    return HomeworkSubmissionAttachment(
      id: json['id'],
      fileName: json['fileName'],
    );
  }
}