import 'package:flutter/material.dart';

import 'waveform_player.dart';

class ReplyCard extends StatelessWidget {
  final String username;
  final String text;
  final int level;
  final bool isVoice;
  final String? duration;
  final int? durationSeconds;
  final String? audioUrl;
  final bool isLast;
  final VoidCallback? onReply;

  const ReplyCard({
    super.key,
    required this.username,
    required this.text,
    required this.level,
    this.isVoice = false,
    this.duration,
    this.durationSeconds,
    this.audioUrl,
    this.isLast = false,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: level * 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (level > 0 || !isLast)
            SizedBox(
              width: 24,
              height: isVoice && audioUrl != null ? 120 : 60,
              child: Stack(
                children: [
                  Positioned(
                    left: 11,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  if (level > 0)
                    Positioned(
                      left: 11,
                      top: 10,
                      width: 12,
                      height: 2,
                      child: Container(color: Colors.grey.shade300),
                    ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (level > 0)
                        const Text('↳ ', style: TextStyle(color: Colors.grey)),
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (onReply != null)
                        TextButton(
                          onPressed: onReply,
                          child: const Text('Reply', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (isVoice && audioUrl != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (duration != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              duration!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        WaveformPlayer(
                          audioUrl: audioUrl!,
                          compact: true,
                          knownDuration: durationSeconds != null
                              ? Duration(seconds: durationSeconds!)
                              : null,
                        ),
                      ],
                    )
                  else if (isVoice)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(text, style: TextStyle(color: Colors.blue.shade900)),
                        ],
                      ),
                    )
                  else
                    Text(
                      text,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
