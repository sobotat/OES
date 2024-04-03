
class Review {

  Review({
    required this.questionId,
    required this.points
  });

  int questionId;
  int? points;

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'points': points,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      questionId: json['questionId'],
      points: json['points']
    );
  }
}