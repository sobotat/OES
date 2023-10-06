
import 'package:oes/src/objects/courseItems/ExamItem.dart';

class Test extends ExamItem {

  Test({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.scheduled,
    required super.end,
    required super.duration,
    required super.isVisible,
    required this.password,
    required this.maxAttempts,
  }) : super(type: 'test');

  int maxAttempts;
  String password;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'id': id,
        'name': name,
        'created': created.toUtc().toString(),
        'createdById': createdById,
        'isVisible': isVisible,
        'scheduled': scheduled.toUtc().toString(),
        'end': end.toUtc().toString(),
        'duration': duration,
        'password': password,
        'maxAttempts': maxAttempts,
      });
  }

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      name: json['name'],
      created: DateTime.tryParse(json['created'])!,
      createdById: json['createdById'],
      isVisible: json['isVisible'],
      scheduled: DateTime.tryParse(json['scheduled'])!,
      end: DateTime.tryParse(json['end'])!,
      duration: json['duration'],
      password: json['password'],
      maxAttempts: json['maxAttempts'],
    );
  }
}