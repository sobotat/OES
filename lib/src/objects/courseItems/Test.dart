
import 'package:oes/src/objects/courseItems/ExamItem.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionFactory.dart';

class Test extends ExamItem {

  Test({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.scheduled,
    required super.end,
    required super.isVisible,
    required super.questions,
    required this.duration,
    required this.maxAttempts,
    required this.password,
  }) : super(type: 'test');

  int duration;
  int maxAttempts;
  String? password;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'duration': duration,
        'maxAttempts': maxAttempts,
      });
  }

  factory Test.fromJson(Map<String, dynamic> json) {
    List<Question> questionsList = [];
    for(Map<String, dynamic> questionJson in json['questions'] ?? []) {
      Question? question = QuestionFactory.fromJson(questionJson);
      if (question == null) continue;
      questionsList.add(question);
    }
    
    return Test(
      id: json['id'],
      name: json['name'],
      created: DateTime.tryParse(json['created'])!,
      createdById: json['createdById'],
      isVisible: json['isVisible'],
      scheduled: DateTime.tryParse(json['scheduled'])!,
      end: DateTime.tryParse(json['end'])!,
      duration: json['duration'],
      questions: questionsList,
      maxAttempts: json['maxAttempts'],
      password: json['password']
    );
  }
}

class TestInfo {

  TestInfo({
    required this.name,
    required this.end,
    required this.duration,
    required this.maxAttempts,
    required this.attempts,
    required this.hasPassword,
  });

  String name;
  DateTime end;
  int duration;
  int maxAttempts;
  List<TestAttempt> attempts;
  bool hasPassword;

  factory TestInfo.fromJson(Map<String, dynamic> json) {
    List<TestAttempt> attemptsList = [];
    for(Map<String, dynamic> attemptJson in json['attempts'] ?? []) {
      attemptsList.add(TestAttempt.fromJson(attemptJson));
    }

    return TestInfo(
      name: json['name'],
      end: DateTime.tryParse(json['end'])!,
      duration: json['duration'],
      attempts: attemptsList,
      maxAttempts: json['maxAttempts'],
      hasPassword: json['hasPassword'],
    );
  }
}

class TestAttempt{

  TestAttempt({
    required this.points,
    required this.status,
    required this.submitted,
  });

  int points;
  String status;
  DateTime submitted;

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    return TestAttempt(
      points: json['points'],
      status: json['status'],
      submitted: DateTime.tryParse(json['submitted'])!,
    );
  }
}

class TestSubmission {

  TestSubmission({
    required this.id,
    required this.testId,
    required this.status,
    required this.submittedAt,
    required this.gradedAt,
    required this.totalPoints
  });

  int id;
  int testId;
  String status;
  DateTime submittedAt;
  DateTime? gradedAt;
  int totalPoints;

  factory TestSubmission.fromJson(Map<String, dynamic> json) {
    return TestSubmission(
      id: json['id'],
      testId: json['testId'],
      status: json['status'],
      submittedAt: DateTime.tryParse(json['submittedAt'])!,
      gradedAt: json['gradedAt'] != null ? DateTime.tryParse(json['gradedAt'])! : null,
      totalPoints: json['totalPoints']
    );
  }
}