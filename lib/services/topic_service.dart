import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../models/topic.dart';
import 'supabase_client.dart';

class TopicService {
  TopicService({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  Stream<List<Topic>> watchTopics() {
    return _client
        .from('topics')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Topic.fromJson).toList());
  }

  Future<void> createTopic({
    required String name,
    required Profile profile,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw TopicException('Topic name is required.');
    }

    final nameLower = trimmed.toLowerCase();
    final existing = await _client
        .from('topics')
        .select('id')
        .eq('name_lower', nameLower)
        .maybeSingle();

    if (existing != null) {
      throw TopicException('A topic with this name already exists.');
    }

    final topic = Topic(
      id: '',
      name: trimmed,
      nameLower: nameLower,
      createdBy: profile.userId,
      authorUsername: profile.username,
      createdAt: DateTime.now(),
    );

    await _client.from('topics').insert(topic.toInsertJson());
  }
}

class TopicException implements Exception {
  final String message;
  TopicException(this.message);

  @override
  String toString() => message;
}
