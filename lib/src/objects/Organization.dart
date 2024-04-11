
class Organization {

  Organization({
    required this.name,
    required this.url,
  });

  String name;
  String url;

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'],
      url: json['uri'],
    );
  }

}