
import 'package:oes/Src/Objects/User.dart';
import 'package:oes/src/Objects/Course.dart';
import 'package:oes/src/RestApi/CourseGateway.dart';

class CourseGatewayTemp implements CourseGateway {

  @override
  Future<List<Course>> getUserCourses(User user) {
    // TODO: implement getUserCourses
    throw UnimplementedError();
  }

}