
abstract class ApiObject {

  ApiObject({
    required this.id,
  });

  int id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiObject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }
}