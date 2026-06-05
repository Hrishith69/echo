import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../widgets/post_card.dart';

class TopicPostsScreen extends StatefulWidget {
  final String topicId;
  final String topicName;

  const TopicPostsScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<TopicPostsScreen> createState() => _TopicPostsScreenState();
}

class _TopicPostsScreenState extends State<TopicPostsScreen> {
  final _postService = PostService();
  late final Stream<List<Post>> _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = _postService.watchPostsByTopic(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicName)),
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
              child: Text('No posts in this topic yet. Tap + to start.'),
            );
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                username: post.authorUsername,
                topic: widget.topicName,
                subject: post.subject,
                duration: post.formattedDuration,
                replyCount: post.replyCount,
                onTap: () => context.go('/posts/${post.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/topics/${widget.topicId}/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
