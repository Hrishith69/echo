import 'package:flutter/material.dart';
import 'package:echo_app/widgets/waveform_player.dart';
import 'package:echo_app/widgets/reply_card.dart';

class ThreadScreen extends StatelessWidget {
  const ThreadScreen({super.key});

  // Mock data: replies with hierarchy levels
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // TOP SECTION: Topic label and subject
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic label
                    Text(
                      'Ask Echo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    // Subject text
                    Text(
                      'Why do people ghost?',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    // AUDIO PLAYER SECTION
                    const WaveformPlayer(
                      audioUrl:
                          'https://samplelib.com/lib/preview/mp3/sample-3s.mp3',
                    ),
                    const SizedBox(height: 24),
                    // REPLIES SECTION
                    Text(
                      'Replies',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Build replies thread
                    ..._buildReplyThread(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // BOTTOM REPLY BAR
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Reply...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // TODO: Implement voice recording
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build reply thread with hierarchy
  List<Widget> _buildReplyThread(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < replies.length; i++) {
      final reply = replies[i];
      bool isLast = i == replies.length - 1;

      widgets.add(
        ReplyCard(
          username: reply['username'],
          text: reply['text'],
          level: reply['level'],
          isVoice: reply['isVoice'] ?? false,
          duration: reply['duration'],
          isLast: isLast,
        ),
      );
    }
    return widgets;
  }
}
