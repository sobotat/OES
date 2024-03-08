
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/api/ApiCourseGateway.dart';

abstract class CourseGateway {

  static final CourseGateway instance = ApiCourseGateway();

  Future<List<Course>> getUserCourses(SignedUser user);
  Future<Course?> getCourse(int id);
  Future<Course?> createCourse(Course course);
  Future<bool> updateCourse(Course course);
  Future<bool> deleteCourse(Course course);

  Future<bool> joinCourse(String code);
  Future<String?> generateCode(Course course);
  Future<String?> getCode(Course course);

  Future<List<CourseItem>> getCourseItems(int id);
  Future<List<User>> getCourseTeachers(int id);
  Future<List<User>> getCourseStudents(int id);
  Future<List<UserQuiz>> getUserQuizzes(SignedUser user);
  Future<UserQuiz> getUserQuiz(SignedUser user, int courseId, int itemId);

  void clearIdentityMap();
}