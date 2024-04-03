
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
}