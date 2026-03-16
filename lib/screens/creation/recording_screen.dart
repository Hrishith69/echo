import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/audio_record_service.dart';

class RecordingScreen extends StatefulWidget {
  final bool isReply;
  const RecordingScreen({super.key, this.isReply = false});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  static const int postMaxSeconds = 40;
  static const int replyMaxSeconds = 20;

  final AudioRecordService _audioRecordService = AudioRecordService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _timer;
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isPlaying = false;
  int _elapsedSeconds = 0;
  String? _recordedFilePath;

  int get _maxSeconds => widget.isReply ? replyMaxSeconds : postMaxSeconds;
  String get _recordingLabel => widget.isReply ? 'Recording reply...' : 'Recording...';

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    await _audioRecordService.init();
    await _startRecording();
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    final filename = 'echo_record_${DateTime.now().millisecondsSinceEpoch}.aac';
    final outputPath = File('${dir.path}/$filename').path;

    await _audioRecordService.startRecording(outputPath);
    setState(() {
      _isRecording = true;
      _hasRecorded = false;
      _elapsedSeconds = 0;
      _recordedFilePath = outputPath;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });
      if (_elapsedSeconds >= _maxSeconds) {
        await _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    _timer?.cancel();
    final resultPath = await _audioRecordService.stopRecording();
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
      _recordedFilePath = resultPath ?? _recordedFilePath;
    });
  }

  Future<void> _playPreview() async {
    if (_recordedFilePath == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
      return;
    }
    try {
      await _audioPlayer.setFilePath(_recordedFilePath!);
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (_) {
      // ignore playback errors
    }
  }

  String _formatTimer(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void _publish() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isReply ? 'Reply posted' : 'Post published'),
        duration: const Duration(milliseconds: 900),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _audioRecordService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSeconds = _elapsedSeconds.clamp(0, _maxSeconds);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReply ? 'Voice Reply' : 'Voice Post'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _hasRecorded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Audio recorded',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _playPreview,
                          child: Text(_isPlaying ? 'Pause Preview' : 'Play Preview'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _publish,
                          child: const Text('Publish'),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _recordingLabel,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_formatTimer(currentSeconds)} / ${_formatTimer(_maxSeconds)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
