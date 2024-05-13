
import 'package:oes/src/objects/SharePermission.dart';
import 'package:oes/src/objects/User.dart';

class ShareUser extends User {

  ShareUser({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.username,
    required this.permission
  });

  SharePermission permission;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'permission': permission,
      });
  }

  factory ShareUser.fromJson(Map<String, dynamic> json) {
    return ShareUser(
      id: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      permission: SharePermission.values.where((element) => element.index == json["permission"]).first,
    );
  }
}