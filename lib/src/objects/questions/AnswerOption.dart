
class AnswerOption {

  AnswerOption({
    required this.questionId,
    required this.id,
    required this.text,
  });

  int questionId;
  int id;
  String text;

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'id': id,
      'text': text
    };
  }

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      questionId: json['questionId'],
      id: json['id'],
      text: json['text']
    );
  }

  @override
  String toString() {
    return '{questionId: $questionId, id: $id, text: $text}';
  }
}