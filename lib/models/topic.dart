class Topic {
  final String id;
  final String name;
  final String nameLower;
  final String createdBy;
  final String authorUsername;
  final DateTime createdAt;

  const Topic({
    required this.id,
    required this.name,
    required this.nameLower,
    required this.createdBy,
    required this.authorUsername,
    required this.createdAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      nameLower: json['name_lower'] as String,
      createdBy: json['created_by'] as String,
      authorUsername: json['author_username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'name_lower': nameLower,
      'created_by': createdBy,
      'author_username': authorUsername,
    };
  }
}
