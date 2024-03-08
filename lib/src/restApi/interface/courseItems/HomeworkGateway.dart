
import 'package:dio/dio.dart';
import 'package:oes/src/restApi/api/courseItems/ApiHomeworkGateway.dart';

abstract class HomeworkGateway {

  static final HomeworkGateway instance = ApiHomeworkGateway();

  Future<bool> submit(String text, MultipartFile? file, { Function(double progress)? onProgress });
}