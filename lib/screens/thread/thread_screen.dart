import 'package:flutter/material.dart';

class ThreadScreen extends StatelessWidget {
  const ThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic label
            Text(
              'Ask Echo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // Subject text
            Text(
              'Why do I overthink everything?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Voice player card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Waveform placeholder
                    Expanded(
                      child: Container(
                        height: 40,
                        color: Colors.grey[300],
                        child: const Center(child: Text('Waveform')),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Duration label
                    const Text('2:15'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Replies section
            Expanded(
              child: ListView(
                children: [
                  // Jess
                  _buildReply('Jess', 'Great topic! Listening now!', 0),
                  const SizedBox(height: 8),
                  // Mike voice reply
                  _buildVoiceReply('Mike', 'Same here honestly', '0:18', 16),
                  const SizedBox(height: 8),
                  // Mike text reply
                  _buildReply('Mike', 'That\'s what I was thinking too.', 16),
                  const SizedBox(height: 8),
                  // Sara voice reply
                  _buildVoiceReply('Sara', 'I feel the same way...', '', 0),
                  const SizedBox(height: 8),
                  // Mike reply to Sara
                  _buildReply('Mike', 'Frustrating, right?', 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Reply...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              child: IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReply(String username, String text, double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildVoiceReply(String username, String text, String duration, double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_arrow),
                const SizedBox(width: 8),
                Text(text),
                if (duration.isNotEmpty) ...[
                  const Spacer(),
                  Text(duration),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
