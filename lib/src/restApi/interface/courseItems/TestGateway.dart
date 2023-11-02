
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/api/courseItems/ApiTestGateway.dart';
import 'package:oes/src/restApi/mock/courseItems/MockTestGateway.dart';

abstract class TestGateway {

  static final TestGateway instance = AppApi.instance.useMockApi ? MockTestGateway() : ApiTestGateway();

  Future<Test?> get(int courseId, int id);

}