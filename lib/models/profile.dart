class Profile {
  final String userId;
  final String username;
  final DateTime createdAt;

  const Profile({
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['id'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id': userId,
      'username': username,
      'username_lower': username.toLowerCase(),
    };
  }
}
