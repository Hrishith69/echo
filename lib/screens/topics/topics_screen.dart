import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/echo_auth_provider.dart';
import '../../services/topic_service.dart';
import '../../widgets/sidebar_menu.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final _topicService = TopicService();

  Future<void> _showAddTopicDialog() async {
    final auth = context.read<EchoAuthProvider>();
    final profile = auth.profile;
    if (profile == null) return;

    final controller = TextEditingController();
    String? error;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add topic'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Topic name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _topicService.createTopic(
                    name: controller.text,
                    profile: profile,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                } on TopicException catch (e) {
                  setDialogState(() => error = e.message);
                } catch (_) {
                  setDialogState(() => error = 'Could not create topic.');
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Topics')),
      drawer: const SidebarMenu(),
      body: StreamBuilder(
        stream: _topicService.watchTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final topics = snapshot.data ?? [];
          if (topics.isEmpty) {
            return const Center(
              child: Text('No topics yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ListTile(
                leading: const Icon(Icons.topic),
                title: Text(topic.name),
                subtitle: Text('by ${topic.authorUsername}'),
                onTap: () => context.go(
                  '/topics/${topic.id}?name=${Uri.encodeComponent(topic.name)}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTopicDialog,
        tooltip: 'Add topic',
        child: const Icon(Icons.add),
      ),
    );
  }
}
