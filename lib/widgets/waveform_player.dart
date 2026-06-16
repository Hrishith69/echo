import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import 'waveform_bars.dart';

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
      await audio.pause();
    } else if (isActive && !audio.isPlaying) {
      await audio.resume();
    } else {
      try {
        await audio.play(widget.audioUrl);
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
    final progress = maxMs == 0
        ? 0.0
        : currentPosition.inMilliseconds / maxMs;

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
          WaveformBars(
            seed: widget.audioUrl,
            progress: progress,
            compact: widget.compact,
            barCount: widget.compact ? 24 : 32,
          ),
          SizedBox(height: widget.compact ? 6 : 8),
          Slider(
            min: 0,
            max: maxMs > 0 ? maxMs : 1,
            value: (currentPosition.inMilliseconds.toDouble())
                .clamp(0, maxMs > 0 ? maxMs : 1),
            onChanged: isActive && maxMs > 0
                ? (value) =>
                    audio.seek(Duration(milliseconds: value.toInt()))
                : null,
          ),
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
