
import 'package:oes/src/objects/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/restApi/mock/MockCourseGateway.dart';

abstract class CourseGateway {

  static CourseGateway gateway = MockCourseGateway.instance;

  Future<List<Course>> getUserCourses(User user);

  Future<Course?> getCourse(int id);

  Future<List<CourseItem>> getCourseItems(int id);
}