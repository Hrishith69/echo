import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';


class WaveformPlayer extends StatefulWidget {
  final String audioUrl;
  final bool compact;
  final Duration? knownDuration;

  const WaveformPlayer({
    super.key,
    required this.audioUrl,
    this.compact = false,
    this.knownDuration,
  });

  @override
  State<WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<WaveformPlayer> {
  // Generate static bar heights based on the audioUrl as a seed.
  // This ensures the waveform signature is consistent for each audio file.
  List<double> _barHeights(int barCount) {
    final random = Random(widget.audioUrl.hashCode);
    return List.generate(barCount, (_) => 0.25 + random.nextDouble() * 0.75);
  }

  Widget _buildWaveformBars(double currentProgress, double maxWidth) {
    final height = widget.compact ? 28.0 : 40.0;
    const barWidth = 3.0; // Fixed bar width
    const gap = 2.0; // Fixed gap between bars
    final barCount = ((maxWidth + gap) / (barWidth + gap)).floor();

    if (barCount <= 0) {
      return SizedBox(height: height);
    }

    final heights = _barHeights(barCount);
    const playedColor = Colors.blueAccent;
    final unplayedColor = Colors.grey.shade400;
    final clampedProgress = currentProgress.clamp(0.0, 1.0);
    final playedBars = (barCount * clampedProgress).floor();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute bars evenly
        children: [
          for (var i = 0; i < barCount; i++)
            Container(
              width: barWidth,
              height: height * heights[i],
              decoration: BoxDecoration(
                color: i < playedBars ? playedColor : unplayedColor,
                borderRadius: BorderRadius.circular(barWidth / 2), // Half of width for rounded caps
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _requestDurationIfNeeded();
  }

  @override
  void didUpdateWidget(WaveformPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl ||
        oldWidget.knownDuration != widget.knownDuration) {
      _requestDurationIfNeeded();
    }
  }

  void _requestDurationIfNeeded() {
    if (widget.audioUrl.isEmpty) return;
    if (widget.knownDuration != null && widget.knownDuration! > Duration.zero) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AudioService>().preloadDuration(widget.audioUrl);
    });
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayPause(AudioService audio) async {
    if (widget.audioUrl.isEmpty) return;
    final isActive = audio.currentUrl == widget.audioUrl;
    if (isActive && audio.isPlaying) {
      audio.pause();
    } else if (isActive && !audio.isPlaying) {
      audio.resume();
    } else {
      try {
        audio.play(widget.audioUrl);
      } catch (e) {
        debugPrint('Audio load error: $e');
      }
    }
  }

  Duration? _resolveDuration(AudioService audio, bool isActive) {
    if (isActive && audio.duration > Duration.zero) {
      return audio.duration;
    }
    if (widget.knownDuration != null && widget.knownDuration! > Duration.zero) {
      return widget.knownDuration;
    }
    final cached = audio.durationFor(widget.audioUrl);
    if (cached != null && cached > Duration.zero) {
      return cached;
    }
    return null;
  }

  void _onSeek(BuildContext context, Offset localPosition, double width) {
    final audio = context.read<AudioService>();
    final isActive = audio.currentUrl == widget.audioUrl;
    final totalDuration = _resolveDuration(audio, isActive);

    if (!isActive ||
        totalDuration == null ||
        totalDuration.inMilliseconds <= 0) {
      return;
    }

    final progress = (localPosition.dx / width).clamp(0.0, 1.0);
    final seekPosition =
        Duration(milliseconds: (totalDuration.inMilliseconds * progress).round());
    audio.seek(seekPosition);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl.isEmpty) {
      return Container(
        padding: EdgeInsets.all(widget.compact ? 8 : 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: widget.compact ? 18 : 22),
            const SizedBox(width: 8),
            Text(
              'Audio unavailable',
              style: TextStyle(fontSize: widget.compact ? 11 : 13),
            ),
          ],
        ),
      );
    }

    final audio = context.watch<AudioService>();
    final isActive = audio.currentUrl == widget.audioUrl;
    final isPlaying = isActive && audio.isPlaying;
    final currentPosition = isActive ? audio.position : Duration.zero;
    final totalDuration = _resolveDuration(audio, isActive);
    final isLoadingDuration =
        totalDuration == null && audio.isDurationLoading(widget.audioUrl);

    final maxMs = totalDuration?.inMilliseconds.toDouble() ?? 0;
    final progress = maxMs == 0 ? 0.0 : currentPosition.inMilliseconds / maxMs;

    final durationLabel = isLoadingDuration
        ? '${_format(currentPosition)} / --:--'
        : '${_format(currentPosition)} / ${_format(totalDuration ?? Duration.zero)}';

    return Container(
      padding: EdgeInsets.all(widget.compact ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    _onSeek(context, details.localPosition, constraints.maxWidth),
                onHorizontalDragStart: (details) =>
                    _onSeek(context, details.localPosition, constraints.maxWidth),
                onHorizontalDragUpdate: (details) =>
                    _onSeek(context, details.localPosition, constraints.maxWidth),
                child: _buildWaveformBars(
                  progress,
                  constraints.maxWidth,
                ),
              );
            },
          ),
          SizedBox(height: widget.compact ? 4 : 8),
          Row(
            children: [
              IconButton(
                iconSize: widget.compact ? 20 : 24,
                padding: widget.compact ? EdgeInsets.zero : null,
                constraints: widget.compact
                    ? const BoxConstraints(minWidth: 32, minHeight: 32)
                    : null,
                onPressed: () => _togglePlayPause(audio),
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              if (isLoadingDuration)
                SizedBox(
                  width: widget.compact ? 14 : 16,
                  height: widget.compact ? 14 : 16,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              if (isLoadingDuration) const SizedBox(width: 8),
              Text(
                durationLabel,
                style: TextStyle(fontSize: widget.compact ? 11 : 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
