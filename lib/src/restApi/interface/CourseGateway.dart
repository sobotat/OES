
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/restApi/api/ApiCourseGateway.dart';

abstract class CourseGateway {

  static final CourseGateway instance = ApiCourseGateway();

  Future<List<Course>> getUserCourses(User user);
  Future<Course?> get(int id);
  Future<Course?> create(Course course);
  Future<bool> update(Course course);
  Future<bool> delete(Course course);

  Future<bool> join(String code);
  Future<String?> generateCode(Course course);
  Future<String?> getCode(Course course);

  Future<List<CourseItem>> getItems(int id);
  Future<List<User>> getTeachers(int id);
  Future<List<User>> getStudents(int id);
  Future<List<User>> getUsers(int id);

}