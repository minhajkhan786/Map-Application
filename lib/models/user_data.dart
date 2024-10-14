class LogedInUser {
  LogedInUser({
    required this.image,
    required this.name,
    required this.email,
    required this.uuid
  });

  late final String image;
  late final String name;
  late final String email;
  late final String uuid;

  LogedInUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    email = json['email'] ?? '';
    uuid = json['uuid'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['email'] = email;
    data['uuid'] = uuid;
    return data;
  }
}