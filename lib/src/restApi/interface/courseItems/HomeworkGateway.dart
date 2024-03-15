
import 'package:dio/dio.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/restApi/api/courseItems/ApiHomeworkGateway.dart';

abstract class HomeworkGateway {

  static final HomeworkGateway instance = ApiHomeworkGateway();

  Future<Homework?> get(int id);
  Future<Homework?> create(int courseId, Homework homework);
  Future<Homework?> update(Homework homework);
  Future<bool> delete(int id);
  Future<bool> submit(int id, String text, List<MultipartFile> files, { Function(double progress)? onProgress });
}