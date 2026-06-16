import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/profile.dart';
import '../../models/topic.dart';
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
  late final Stream<List<Topic>> _topicsStream;

  @override
  void initState() {
    super.initState();
    _topicsStream = _topicService.watchTopics();
  }

  Future<void> _showAddTopicDialog() async {
    final profile = context.read<EchoAuthProvider>().profile;
    if (profile == null) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => _AddTopicDialog(
        topicService: _topicService,
        profile: profile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Topics')),
      drawer: const SidebarMenu(),
      body: StreamBuilder<List<Topic>>(
        stream: _topicsStream,
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
                onTap: () => context.push(
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

class _AddTopicDialog extends StatefulWidget {
  final TopicService topicService;
  final Profile profile;

  const _AddTopicDialog({
    required this.topicService,
    required this.profile,
  });

  @override
  State<_AddTopicDialog> createState() => _AddTopicDialogState();
}

class _AddTopicDialogState extends State<_AddTopicDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await widget.topicService.createTopic(
        name: _controller.text,
        profile: widget.profile,
      );
      if (mounted) Navigator.of(context).pop();
    } on TopicException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not create topic.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add topic'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Topic name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            enabled: !_saving,
            onSubmitted: (_) => _saving ? null : _create(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _create,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
