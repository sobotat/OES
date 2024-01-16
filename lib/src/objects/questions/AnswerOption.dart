
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

}