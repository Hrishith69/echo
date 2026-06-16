import 'dart:math';

import 'package:flutter/material.dart';

/// Static bar visualization derived from [seed]. Progress tints played portion.
class WaveformBars extends StatelessWidget {
  final String seed;
  final double progress;
  final bool compact;
  final int barCount;

  const WaveformBars({
    super.key,
    required this.seed,
    this.progress = 0,
    this.compact = false,
    this.barCount = 32,
  });

  List<double> _barHeights() {
    final random = Random(seed.hashCode);
    return List.generate(barCount, (_) => 0.25 + random.nextDouble() * 0.75);
  }

  @override
  Widget build(BuildContext context) {
    final heights = _barHeights();
    final height = compact ? 28.0 : 40.0;
    final barWidth = compact ? 2.5 : 3.0;
    final gap = compact ? 2.0 : 2.5;
    final playedColor = Colors.blueAccent;
    final unplayedColor = Colors.grey.shade400;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final playedBars = (barCount * clampedProgress).floor();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < barCount; i++) ...[
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: barWidth,
                  height: height * heights[i],
                  decoration: BoxDecoration(
                    color: i < playedBars ? playedColor : unplayedColor,
                    borderRadius: BorderRadius.circular(barWidth),
                  ),
                ),
              ),
            ),
            if (i < barCount - 1) SizedBox(width: gap),
          ],
        ],
      ),
    );
  }
}
