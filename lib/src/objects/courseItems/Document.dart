
import 'package:oes/src/objects/courseItems/CourseItem.dart';

class Document extends CourseItem {

  Document({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible
  }) : super(type: 'document');

}