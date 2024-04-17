
class AnswerOption {

  AnswerOption({
    required this.questionId,
    required this.id,
    required this.text,
    this.similarityPercentage,
  });

  int questionId;
  int id;
  String text;
  double? similarityPercentage;

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
        text: json['text'],
        similarityPercentage: json['similarityPercentage'] != null ? json['similarityPercentage'] + 0.0 : null
    );
  }

  @override
  String toString() {
    return '{questionId: $questionId, id: $id, text: $text, similarityPercentage: $similarityPercentage}';
  }
}