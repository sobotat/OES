
import 'package:dio/dio.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/restApi/api/courseItems/ApiHomeworkGateway.dart';

abstract class HomeworkGateway {

  static final HomeworkGateway instance = ApiHomeworkGateway();

  Future<Homework?> get(int id);
  Future<int?> getScore(int id, int userId);
  Future<List<HomeworkSubmission>> getSubmission(int id);
  Future<List<HomeworkSubmission>> getUserSubmission(int id, int userId);
  Future<List<int>?> getAttachment(int attachmentId, { Function(double progress)? onProgress });

  Future<Homework?> create(int courseId, Homework homework);
  Future<Homework?> update(Homework homework);
  Future<bool> delete(int id);
  Future<bool> submit(int id, String text, List<MultipartFile> files, { Function(double progress)? onProgress });
  Future<bool> submitScore(int id, int userId, int points);
  Future<bool> submitReviewText(int id, int submitId, String text);
}