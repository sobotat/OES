
class QuestionOption {

  QuestionOption({
    required this.id,
    required this.text,
    required this.points
  });

  int id;
  String text;
  int points;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'points': points
    };
  }

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'],
      text: json['text'],
      points: json['points'] ?? 0
    );
  }

  @override
  String toString() {
    return '{id: $id, text: $text, points: $points}';
  }
}