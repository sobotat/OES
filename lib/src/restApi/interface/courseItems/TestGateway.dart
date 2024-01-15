
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/api/courseItems/ApiTestGateway.dart';

abstract class TestGateway {

  static final TestGateway instance = ApiTestGateway();

  Future<Test?> get(int courseId, int id);
  Future<Test?> create(int courseId, Test test);
  Future<Test?> update(int courseId, Test test);

}