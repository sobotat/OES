
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';

class MockTestGateway implements TestGateway {

  @override
  Future<Test?> get(int courseId, int id) async {
    return Test(
      id: 1,
      name: 'Testing test',
      created: DateTime.now().subtract(const Duration(days: 1)),
      createdById: 1,
      scheduled: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
      duration: 40,
      isVisible: true,
      maxAttempts: 3,
      questions: [],
    );
  }

  @override
  Future<Test?> create(int courseId, Test test) async {
    return Test(
      id: 1,
      name: 'Testing test',
      created: DateTime.now().subtract(const Duration(days: 1)),
      createdById: 1,
      scheduled: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
      duration: 40,
      isVisible: true,
      maxAttempts: 3,
      questions: [],
    );
  }

  @override
  Future<Test?> update(int courseId, Test test) async {
    return Test(
      id: 1,
      name: 'Testing test',
      created: DateTime.now().subtract(const Duration(days: 1)),
      createdById: 1,
      scheduled: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
      duration: 40,
      isVisible: true,
      maxAttempts: 3,
      questions: [],
    );
  }

}