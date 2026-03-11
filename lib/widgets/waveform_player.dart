import 'package:flutter/material.dart';

class WaveformPlayer extends StatelessWidget {
  const WaveformPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey[300],
      child: const Center(
        child: Text('Waveform Player (mock)'),
      ),
    );
  }
}
