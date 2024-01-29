
import 'package:oes/src/objects/courseItems/Note.dart';
import 'package:oes/src/restApi/api/courseItems/ApiNoteGateway.dart';

abstract class NoteGateway {

  static final NoteGateway instance = ApiNoteGateway();

  Future<Note?> get(int courseId, int id);
  Future<Note?> create(int courseId, Note note);
  Future<Note?> update(int courseId, Note note);
  Future<bool> delete(int courseId, int id);
}