enum CommentType { text, voice }

class Comment {
  final String id;
  final String postId;
  final String? parentCommentId;
  final String authorId;
  final String authorUsername;
  final CommentType type;
  final String? text;
  final String? audioUrl;
  final String? audioPath;
  final int? durationSeconds;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    this.parentCommentId,
    required this.authorId,
    required this.authorUsername,
    required this.type,
    this.text,
    this.audioUrl,
    this.audioPath,
    this.durationSeconds,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json, {String? audioUrl}) {
    final typeStr = json['type'] as String;
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String,
      type: typeStr == 'voice' ? CommentType.voice : CommentType.text,
      text: json['text'] as String?,
      audioPath: json['audio_path'] as String?,
      audioUrl: audioUrl,
      durationSeconds: json['duration_seconds'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'post_id': postId,
      'parent_comment_id': parentCommentId,
      'author_id': authorId,
      'author_username': authorUsername,
      'type': type == CommentType.voice ? 'voice' : 'text',
      'text': text,
      'audio_path': audioPath,
      'duration_seconds': durationSeconds,
    };
  }

  String? get formattedDuration {
    if (durationSeconds == null) return null;
    final min = durationSeconds! ~/ 60;
    final sec = durationSeconds! % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}
