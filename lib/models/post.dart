class Post {
  final String id;
  final String topicId;
  final String subject;
  final String authorId;
  final String authorUsername;
  final String audioUrl;
  final String audioPath;
  final int durationSeconds;
  final int replyCount;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.topicId,
    required this.subject,
    required this.authorId,
    required this.authorUsername,
    required this.audioUrl,
    required this.audioPath,
    required this.durationSeconds,
    required this.replyCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json, {String audioUrl = ''}) {
    return Post(
      id: json['id'] as String,
      topicId: json['topic_id'] as String,
      subject: json['subject'] as String,
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String,
      audioPath: json['audio_path'] as String,
      audioUrl: audioUrl,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      replyCount: json['reply_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get formattedDuration {
    final min = durationSeconds ~/ 60;
    final sec = durationSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
