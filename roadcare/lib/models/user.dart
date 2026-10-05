class RoadUser {
  final int? id;
  final String name;
  final String email;

  const RoadUser({this.id, required this.name, required this.email});

  // =========================================================
  // FROM DATABASE
  // =========================================================

  factory RoadUser.fromMap(Map<String, dynamic> map) {
    return RoadUser(
      id: map['id'] as int?,
      name: (map['username'] ?? map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
    );
  }

  // =========================================================
  // TO DATABASE
  // =========================================================

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': name, 'email': email};
  }

  // =========================================================
  // COPY WITH
  // =========================================================

  RoadUser copyWith({int? id, String? name, String? email}) {
    return RoadUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'RoadUser(id: $id, name: $name, email: $email)';
  }
}
