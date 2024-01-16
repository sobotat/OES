
class QuestionOption {

  QuestionOption({
    required this.id,
    required this.text,
  });

  int id;
  String text;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text
    };
  }

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'],
      text: json['text']
    );
  }
}