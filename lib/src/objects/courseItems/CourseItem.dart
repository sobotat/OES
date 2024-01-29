
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/ApiObject.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';

class CourseItem extends ApiObject {

  CourseItem({
    required this.type,
    required this.id,
    required this.name,
    required this.created,
    required this.createdById,
    required this.isVisible,
  });

  String type;
  int id;
  String name;
  DateTime created;
  int createdById;
  User? _createdBy;
  bool isVisible;

  Future<User> get createdBy async {
    if (_createdBy != null) return _createdBy!;
    _createdBy = await UserGateway.instance.getUser(createdById);
    return _createdBy!;
  }


  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'type': type,
        'id': id,
        'name': name,
        'created': created.toUtc().toString().replaceAll(' ', 'T'),
        'createdById': createdById,
        'isVisible': isVisible,
      });
  }

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      type: json['type'].toString().toLowerCase(),
      id: json['id'],
      name: json['name'],
      created: DateTime.tryParse(json['created'])!,
      createdById: json['createdById'],
      isVisible: json['isVisible'],
    );
  }
}