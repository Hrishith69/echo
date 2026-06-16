import 'package:flutter/material.dart';

import 'waveform_player.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String topic;
  final String subject;
  final String audioUrl;
  final int durationSeconds;
  final int replyCount;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.username,
    required this.topic,
    required this.subject,
    required this.audioUrl,
    required this.durationSeconds,
    required this.replyCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        username,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topic,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subject,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            WaveformPlayer(
              audioUrl: audioUrl,
              compact: true,
              knownDuration: durationSeconds > 0
                  ? Duration(seconds: durationSeconds)
                  : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 20, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '$replyCount',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  tooltip: 'Save',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
