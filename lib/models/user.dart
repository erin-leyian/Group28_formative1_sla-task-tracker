class AppUser {
  final String id;
  final String name;
  final String role;

  AppUser({required this.id, required this.name, required this.role});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role};

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(id: json['id'], name: json['name'], role: json['role']);
  }
}
