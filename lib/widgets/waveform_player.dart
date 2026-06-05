import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class WaveformPlayer extends StatefulWidget {
  final String audioUrl;
  final bool compact;

  const WaveformPlayer({
    super.key,
    required this.audioUrl,
    this.compact = false,
  });

  @override
  State<WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<WaveformPlayer> {
  final AudioPlayer _player = AudioPlayer();

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  @override
  void didUpdateWidget(WaveformPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _disposeSubscriptions();
      _initAudio();
    }
  }

  Future<void> _initAudio() async {
    try {
      final url = widget.audioUrl;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        await _player.setUrl(url);
      } else {
        await _player.setFilePath(url);
      }

      _durationSub = _player.durationStream.listen((duration) {
        if (!mounted) return;
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      });

      _positionSub = _player.positionStream.listen((position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
        });
      });

      _playerStateSub = _player.playerStateStream.listen((state) {
        if (!mounted) return;

        final playing = state.playing;
        final processing = state.processingState;

        if (processing == ProcessingState.completed) {
          _player.seek(Duration.zero);
          _player.pause();

          setState(() {
            _isPlaying = false;
            _currentPosition = Duration.zero;
          });
        } else {
          setState(() {
            _isPlaying = playing;
          });
        }
      });
    } catch (e) {
      debugPrint('Audio load error: $e');
    }
  }

  void _disposeSubscriptions() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _positionSub = null;
    _durationSub = null;
    _playerStateSub = null;
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _seekAudio(double value) {
    final position = Duration(milliseconds: value.toInt());
    _player.seek(position);
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _disposeSubscriptions();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = _totalDuration.inMilliseconds.toDouble();
    final progress = maxMs == 0
        ? 0.0
        : _currentPosition.inMilliseconds.toDouble();

    return Container(
      padding: EdgeInsets.all(widget.compact ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Slider(
            min: 0,
            max: maxMs > 0 ? maxMs : 1,
            value: progress.clamp(0, maxMs > 0 ? maxMs : 1),
            onChanged: maxMs > 0 ? _seekAudio : null,
          ),
          Row(
            children: [
              IconButton(
                iconSize: widget.compact ? 20 : 24,
                onPressed: _togglePlayPause,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              Text(
                '${_format(_currentPosition)} / ${_format(_totalDuration)}',
                style: TextStyle(fontSize: widget.compact ? 11 : 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
