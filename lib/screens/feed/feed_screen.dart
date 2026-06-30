import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/post.dart';
import '../../services/audio_service.dart';
import '../../services/post_service.dart';
import '../../widgets/post_card.dart';
import '../../widgets/sidebar_menu.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _postService = PostService();
  late final Stream<List<Post>> _postsStream;
  AudioService? _audioService;

  @override
  void initState() {
    super.initState();
    _postsStream = _postService.watchRecentPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioService ??= context.read<AudioService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Echo Feed'),
      ),
      drawer: const SidebarMenu(),
      body: StreamBuilder<List<Post>>(
        stream: _postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(
              child: Text('No voice posts yet. Browse topics to get started.'),
            );
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                username: post.authorUsername,
                topic: post.topicName ?? 'Topic',
                subject: post.subject,
                audioUrl: post.audioUrl,
                durationSeconds: post.durationSeconds,
                replyCount: post.replyCount,
                onTap: () {
                  _audioService?.stop();
                  context.push('/posts/${post.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
