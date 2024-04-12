

import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/restApi/api/courseItems/ApiQuizGateway.dart';

abstract class QuizGateway {

  static final QuizGateway instance = ApiQuizGateway();

  Future<Quiz?> get(int id);
  Future<Quiz?> create(int courseId, Quiz quiz);
  Future<Quiz?> update(Quiz quiz);
  Future<bool> delete(int id);
}