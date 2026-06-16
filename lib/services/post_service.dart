import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';
import '../models/profile.dart';
import 'storage_service.dart';
import 'supabase_client.dart';

class PostService {
  PostService({
    SupabaseClient? client,
    StorageService? storageService,
  })  : _client = client ?? supabase,
        _storage = storageService ?? StorageService();

  final SupabaseClient _client;
  final StorageService _storage;
  final _uuid = const Uuid();

  Stream<List<Post>> watchPostsByTopic(String topicId) {
    return _client
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('topic_id', topicId)
        .order('created_at', ascending: false)
        .asyncMap((rows) => _mapPosts(rows));
  }

  Stream<List<Post>> watchRecentPosts() {
    return _client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((rows) => _mapPosts(rows, includeTopicNames: true));
  }

  Stream<Post?> watchPost(String postId) {
    return _client
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('id', postId)
        .asyncMap((rows) async {
          if (rows.isEmpty) return null;
          final posts = await _mapPosts(rows);
          return posts.first;
        });
  }

  Future<Map<String, int>> _fetchCommentCounts(List<String> postIds) async {
    if (postIds.isEmpty) return {};

    final rows = await _client
        .from('comments')
        .select('post_id')
        .inFilter('post_id', postIds);

    final counts = <String, int>{};
    for (final row in rows) {
      final postId = row['post_id'] as String;
      counts[postId] = (counts[postId] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<Post>> _mapPosts(
    List<Map<String, dynamic>> rows, {
    bool includeTopicNames = false,
  }) async {
    if (rows.isEmpty) return [];

    final postIds = rows.map((row) => row['id'] as String).toList();
    final commentCounts = await _fetchCommentCounts(postIds);

    Map<String, String>? topicNames;
    if (includeTopicNames) {
      final topicIds =
          rows.map((row) => row['topic_id'] as String).toSet().toList();
      final topicRows = await _client
          .from('topics')
          .select('id, name')
          .inFilter('id', topicIds);
      topicNames = {
        for (final topic in topicRows)
          topic['id'] as String: topic['name'] as String,
      };
    }

    return Future.wait(rows.map((row) async {
      final id = row['id'] as String;
      final path = row['audio_path'] as String;
      var url = '';
      try {
        url = await _storage.getPlaybackUrl(path);
      } catch (e) {
        debugPrint('Playback URL error for $path: $e');
      }

      final storedCount = row['reply_count'] as int? ?? 0;
      final derivedCount = commentCounts[id] ?? 0;
      final replyCount =
          derivedCount > storedCount ? derivedCount : storedCount;

      return Post.fromJson(
        row,
        audioUrl: url,
        replyCount: replyCount,
        topicName: topicNames?[row['topic_id'] as String],
      );
    }));
  }

  Future<String> createPost({
    required String topicId,
    required String subject,
    required Profile profile,
    required String localAudioPath,
    required int durationSeconds,
  }) async {
    final trimmedSubject = subject.trim();
    if (trimmedSubject.isEmpty) {
      throw PostException('Subject is required.');
    }

    final postId = _uuid.v4();
    final storagePath = 'voice_posts/${profile.userId}/$postId.aac';

    await _storage.uploadVoiceFile(
      localPath: localAudioPath,
      storagePath: storagePath,
    );

    await _client.from('posts').insert({
      'id': postId,
      'topic_id': topicId,
      'subject': trimmedSubject,
      'author_id': profile.userId,
      'author_username': profile.username,
      'audio_path': storagePath,
      'duration_seconds': durationSeconds,
      'reply_count': 0,
    });

    return postId;
  }
}

class PostException implements Exception {
  final String message;
  PostException(this.message);

  @override
  String toString() => message;
}
