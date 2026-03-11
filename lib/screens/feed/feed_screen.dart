import 'package:flutter/material.dart';
import '../../widgets/post_card.dart';
import '../../widgets/mic_button.dart';
import '../../widgets/sidebar_menu.dart';
import 'package:go_router/go_router.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static final List<Map<String, dynamic>> _mockPosts = [
    {
      'topic': 'Ask Echo',
      'subject': 'Why do people ghost?',
      'duration': '00:21',
      'replyCount': 3,
    },
    {
      'topic': 'Relationships',
      'subject': 'Is silence a form of communication?',
      'duration': '00:17',
      'replyCount': 5,
    },
    {
      'topic': 'Career',
      'subject': 'How do you deal with imposter syndrome?',
      'duration': '00:25',
      'replyCount': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Echo Feed'),
      ),
      drawer: const SidebarMenu(),
      body: ListView.builder(
        itemCount: _mockPosts.length,
        itemBuilder: (context, index) {
          final post = _mockPosts[index];
          return PostCard(
            topic: post['topic'],
            subject: post['subject'],
            duration: post['duration'],
            replyCount: post['replyCount'],
            onTap: () => context.go('/thread'),
          );
        },
      ),
      floatingActionButton: MicButton(
        onPressed: () => context.go('/create'),
      ),
    );
  }
}
