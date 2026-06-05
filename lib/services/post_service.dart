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
        .asyncMap(_mapPosts);
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

  Future<List<Post>> _mapPosts(List<Map<String, dynamic>> rows) async {
    return Future.wait(rows.map((row) async {
      final path = row['audio_path'] as String;
      final url = await _storage.getPlaybackUrl(path);
      return Post.fromJson(row, audioUrl: url);
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
