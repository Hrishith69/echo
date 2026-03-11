import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String topic;
  final String subject;
  final String duration;
  final int replyCount;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.topic,
    required this.subject,
    required this.duration,
    required this.replyCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic label
              Text(
                topic,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Subject text
              Text(
                subject,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Waveform preview placeholder
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Waveform Preview'),
                ),
              ),
              const SizedBox(height: 12),
              // Duration label
              Text(
                duration,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              // Action row
              Row(
                children: [
                  // Reply icon + count
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$replyCount', style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                  const Spacer(),
                  // Save button
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    tooltip: 'Save',
                    onPressed: () {},
                  ),
                  // Share button
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
      ),
    );
  }
}
