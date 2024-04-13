

import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/api/courseItems/ApiUserQuizGateway.dart';

abstract class UserQuizGateway {

  static final UserQuizGateway instance = ApiUserQuizGateway();

  Future<UserQuiz?> get(int id);
  Future<UserQuiz?> create(int courseId, UserQuiz quiz);
  Future<UserQuiz?> update(UserQuiz quiz);
  Future<bool> delete(int id);
}