
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/mock/MockCourseGateway.dart';

abstract class CourseGateway {

  static final CourseGateway instance = MockCourseGateway();

  Future<List<Course>> getUserCourses(SignedUser user);

  Future<Course?> getCourse(int id);

  Future<List<CourseItem>> getCourseItems(int id);
  Future<List<User>> getCourseTeachers(int id);
  Future<List<UserQuiz>> getUserQuizzes(SignedUser user);
  Future<UserQuiz> getUserQuiz(SignedUser user, int courseId, int itemId);

  Future<CourseItem?> getCourseItem(int courseId, int itemId);
}