
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/restApi/api/courseItems/ApiTestGateway.dart';

abstract class TestGateway {

  static final TestGateway instance = ApiTestGateway();

  Future<Test?> get(int id, {String? password});
  Future<Test?> create(int courseId, Test test, String password);
  Future<Test?> update(Test test, String password);
  Future<bool> delete(int id);

  Future<bool> checkTestPassword(int id, String password);
  Future<bool> submit(int id, List<AnswerOption> answers);
  Future<TestInfo?> getInfo(int id);
}