import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/post_service.dart';
import '../../widgets/post_card.dart';

class TopicPostsScreen extends StatelessWidget {
  final String topicId;
  final String topicName;

  const TopicPostsScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  Widget build(BuildContext context) {
    final postService = PostService();

    return Scaffold(
      appBar: AppBar(title: Text(topicName)),
      body: StreamBuilder(
        stream: postService.watchPostsByTopic(topicId),
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
                topic: topicName,
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
        onPressed: () => context.go('/topics/$topicId/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
