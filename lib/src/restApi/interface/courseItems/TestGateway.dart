
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Review.dart';
import 'package:oes/src/restApi/api/courseItems/ApiTestGateway.dart';

abstract class TestGateway {

  static final TestGateway instance = ApiTestGateway();

  Future<Test?> get(int id, {String? password});
  Future<List<TestSubmission>> getUserSubmission(int id, int userId);
  Future<List<AnswerOption>> getAnswers(int id, int submissionId);
  Future<Test?> create(int courseId, Test test, String password);
  Future<Test?> update(Test test, String password);
  Future<bool> delete(int id);

  Future<bool> checkTestPassword(int id, String password);
  Future<bool> submit(int id, List<AnswerOption> answers);
  Future<bool> submitReview(int id, int submissionId, List<Review> reviews);
  Future<TestInfo?> getInfo(int id);

}