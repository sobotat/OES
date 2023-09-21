
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/CourseGateway.dart';

class ApiCourseGateway implements CourseGateway {

  @override
  Future<Course?> getCourse(int id) {
    // TODO: implement getCourse
    throw UnimplementedError();
  }

  @override
  Future<CourseItem?> getCourseItem(int courseId, int itemId) {
    // TODO: implement getCourseItem
    throw UnimplementedError();
  }

  @override
  Future<List<CourseItem>> getCourseItems(int id) {
    // TODO: implement getCourseItems
    throw UnimplementedError();
  }

  @override
  Future<List<User>> getCourseTeachers(int id) {
    // TODO: implement getCourseTeachers
    throw UnimplementedError();
  }

  @override
  Future<List<Course>> getUserCourses(SignedUser user) {
    // TODO: implement getUserCourses
    throw UnimplementedError();
  }

  @override
  Future<UserQuiz> getUserQuiz(SignedUser user, int courseId, int itemId) {
    // TODO: implement getUserQuiz
    throw UnimplementedError();
  }

  @override
  Future<List<UserQuiz>> getUserQuizzes(SignedUser user) {
    // TODO: implement getUserQuizzes
    throw UnimplementedError();
  }

}