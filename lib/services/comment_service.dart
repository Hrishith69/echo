import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/comment.dart';
import '../models/profile.dart';
import 'storage_service.dart';
import 'supabase_client.dart';

class CommentService {
  CommentService({
    SupabaseClient? client,
    StorageService? storageService,
  })  : _client = client ?? supabase,
        _storage = storageService ?? StorageService();

  final SupabaseClient _client;
  final StorageService _storage;
  final _uuid = const Uuid();

  Stream<List<Comment>> watchComments(String postId) {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .asyncMap(_mapComments);
  }

  Future<List<Comment>> _mapComments(List<Map<String, dynamic>> rows) async {
    return Future.wait(rows.map((row) async {
      final type = row['type'] as String;
      String? audioUrl;
      final audioPath = row['audio_path'] as String?;
      if (type == 'voice' && audioPath != null) {
        audioUrl = await _storage.getPlaybackUrl(audioPath);
      }
      return Comment.fromJson(row, audioUrl: audioUrl);
    }));
  }

  Future<void> createTextComment({
    required String postId,
    required Profile profile,
    required String text,
    String? parentCommentId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw CommentException('Reply cannot be empty.');
    }

    await _client.from('comments').insert({
      'post_id': postId,
      'parent_comment_id': parentCommentId,
      'author_id': profile.userId,
      'author_username': profile.username,
      'type': 'text',
      'text': trimmed,
    });

    await _incrementReplyCount(postId, parentCommentId);
  }

  Future<void> createVoiceComment({
    required String postId,
    required Profile profile,
    required String localAudioPath,
    required int durationSeconds,
    String? parentCommentId,
  }) async {
    final commentId = _uuid.v4();
    final storagePath = 'voice_comments/${profile.userId}/$commentId.aac';

    await _storage.uploadVoiceFile(
      localPath: localAudioPath,
      storagePath: storagePath,
    );

    await _client.from('comments').insert({
      'id': commentId,
      'post_id': postId,
      'parent_comment_id': parentCommentId,
      'author_id': profile.userId,
      'author_username': profile.username,
      'type': 'voice',
      'audio_path': storagePath,
      'duration_seconds': durationSeconds,
    });

    await _incrementReplyCount(postId, parentCommentId);
  }

  Future<void> _incrementReplyCount(
    String postId,
    String? parentCommentId,
  ) async {
    if (parentCommentId != null) return;

    final row = await _client
        .from('posts')
        .select('reply_count')
        .eq('id', postId)
        .single();

    final current = row['reply_count'] as int? ?? 0;
    await _client
        .from('posts')
        .update({'reply_count': current + 1})
        .eq('id', postId);
  }
}

class CommentException implements Exception {
  final String message;
  CommentException(this.message);

  @override
  String toString() => message;
}
