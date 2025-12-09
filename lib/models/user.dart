class User {
  final String id;
  final String name;
  final String email;
  final String picture;
  final String providerUserId;
  final List<String> groupIds;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.picture,
    required this.providerUserId,
    required this.groupIds,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      picture: json['picture'] as String? ?? '',
      providerUserId: json['providerUserId'] as String,
      groupIds: (json['groupIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'picture': picture,
      'providerUserId': providerUserId,
      'groupIds': groupIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
