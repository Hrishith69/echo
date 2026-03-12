import 'package:flutter/material.dart';

class ReplyCard extends StatelessWidget {
  final String username;
  final String text;
  final int level;
  final bool isVoice;
  final String? duration;
  final bool isLast;

  const ReplyCard({
    super.key,
    required this.username,
    required this.text,
    required this.level,
    this.isVoice = false,
    this.duration,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: level * 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread line
          if (level > 0 || !isLast)
            SizedBox(
              width: 24,
              height: 60, // FIX: give stack a bounded height
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
                      child: Container(
                        color: Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            ),

          // Reply content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (level > 0)
                        const Text(
                          "↳ ",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  if (isVoice)
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
                          Icon(
                            Icons.play_arrow,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          if (duration != null && duration!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              duration!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
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