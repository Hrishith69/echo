import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:echo_app/widgets/waveform_player.dart';
import 'package:echo_app/widgets/reply_card.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  static const List<Map<String, dynamic>> replies = [
    {
      "username": "Jess",
      "text": "Great topic! Listening now!",
      "level": 0,
      "isVoice": false
    },
    {
      "username": "Mike",
      "text": "Same here honestly",
      "level": 1,
      "isVoice": true,
      "duration": "0:18"
    },
    {
      "username": "Mike",
      "text": "That's what I was thinking too.",
      "level": 1,
      "isVoice": false
    },
    {
      "username": "Sara",
      "text": "I feel the same way...",
      "level": 0,
      "isVoice": true,
      "duration": "0:32"
    },
    {
      "username": "Mike",
      "text": "Frustrating, right?",
      "level": 2,
      "isVoice": false
    },
  ];

  final TextEditingController _replyController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _replyController.addListener(() {
      setState(() {
        _hasText = _replyController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    if (_replyController.text.trim().isEmpty) return;
    _replyController.clear();
  }

  void _startVoiceReplyRecording() {
    context.go('/record?reply=true');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Thread'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask Echo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Why do people ghost?',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    const WaveformPlayer(
                      audioUrl:
                          'https://samplelib.com/lib/preview/mp3/sample-3s.mp3',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Replies',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildReplyThread(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 12,
            right: 12,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  decoration: const InputDecoration(
                    hintText: 'Reply...',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitReply(),
                ),
              ),
              const SizedBox(width: 8),
              _hasText
                  ? IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitReply,
                    )
                  : IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: _startVoiceReplyRecording,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReplyThread(BuildContext context) {
    return List<Widget>.generate(replies.length, (i) {
      final reply = replies[i];
      bool isLast = i == replies.length - 1;
      return ReplyCard(
        username: reply['username'],
        text: reply['text'],
        level: reply['level'],
        isVoice: reply['isVoice'] ?? false,
        duration: reply['duration'],
        isLast: isLast,
      );
    });
  }
}
