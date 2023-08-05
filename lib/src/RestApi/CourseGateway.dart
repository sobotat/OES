
import 'package:oes/Src/Objects/User.dart';
import 'package:oes/src/Objects/Course.dart';
import 'package:oes/src/RestApi/Temp/CourseGatewayTemp.dart';

abstract class CourseGateway {

  static CourseGateway gateway = CourseGatewayTemp();

  Future<List<Course>> getUserCourses(User user);
}