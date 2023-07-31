
class User {
  User({
    required this.firstName,
    required this.lastName,
    required this.username,
    this.token,
  });

  String firstName;
  String lastName;
  String username;
  String? token;
}