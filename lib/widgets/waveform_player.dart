import 'package:flutter/material.dart';

class WaveformPlayer extends StatefulWidget {
  const WaveformPlayer({super.key});

  @override
  State<WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<WaveformPlayer> {
  bool _isPlaying = false;
  double _progress = 0.3; // Mock progress

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Waveform visualization placeholder
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Waveform Visualization'),
            ),
          ),
          const SizedBox(height: 16),
          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _progress,
                  onChanged: (value) {
                    setState(() {
                      _progress = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text('00:07 / 00:21'),
            ],
          ),
        ],
      ),
    );
  }
}
