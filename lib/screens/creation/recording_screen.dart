import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/echo_auth_provider.dart';
import '../../services/audio_service.dart';
import '../../services/comment_service.dart';
import '../../services/post_service.dart';
import '../../utils/permissions.dart';
import '../../utils/recording_platform.dart';
import '../../services/audio_record_service.dart';

enum RecordingMode { post, reply }

class RecordingScreen extends StatefulWidget {
  final RecordingMode mode;
  final String? topicId;
  final String? postId;
  final String? subject;
  final String? parentCommentId;

  const RecordingScreen({
    super.key,
    required this.mode,
    this.topicId,
    this.postId,
    this.subject,
    this.parentCommentId,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  static const int postMaxSeconds = 40;
  static const int replyMaxSeconds = 20;

  final AudioRecordService _audioRecordService = AudioRecordService();
  final _postService = PostService();
  final _commentService = CommentService();

  Timer? _timer;
  AudioService? _audioService;
  bool _recorderReady = false;
  bool _recordingSupported = false;
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isPublishing = false;
  int _elapsedSeconds = 0;
  String? _recordedFilePath;

  int get _maxSeconds =>
      widget.mode == RecordingMode.reply ? replyMaxSeconds : postMaxSeconds;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioService ??= context.read<AudioService>();
  }

  Future<void> _initRecorder() async {
    _recordingSupported = isVoiceRecordingSupported;
    if (!_recordingSupported) {
      if (mounted) setState(() => _recorderReady = true);
      return;
    }
    await _audioRecordService.init();
    if (mounted) setState(() => _recorderReady = true);
  }

  Future<void> _startRecording() async {
    final granted = await ensureMicrophonePermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required.')),
        );
      }
      return;
    }

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
      setState(() => _elapsedSeconds++);
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
    final audio = _audioService!;
    final isActive = audio.currentUrl == _recordedFilePath;
    if (isActive && audio.isPlaying) {
      await audio.pause();
      return;
    }
    if (isActive && !audio.isPlaying) {
      await audio.resume();
      return;
    }
    try {
      await audio.play(_recordedFilePath!);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play preview.')),
        );
      }
    }
  }

  Future<void> _publish() async {
    if (_recordedFilePath == null || _isPublishing) return;
    final auth = context.read<EchoAuthProvider>();
    final profile = auth.profile;
    if (profile == null) return;

    setState(() => _isPublishing = true);
    try {
      if (widget.mode == RecordingMode.post) {
        final topicId = widget.topicId;
        final subject = widget.subject != null
            ? Uri.decodeComponent(widget.subject!)
            : '';
        if (topicId == null || subject.isEmpty) {
          throw Exception('Missing topic or subject');
        }
        final postId = await _postService.createPost(
          topicId: topicId,
          subject: subject,
          profile: profile,
          localAudioPath: _recordedFilePath!,
          durationSeconds: _elapsedSeconds,
        );
        if (mounted) context.go('/posts/$postId');
      } else {
        final postId = widget.postId;
        if (postId == null) throw Exception('Missing post id');
        await _commentService.createVoiceComment(
          postId: postId,
          profile: profile,
          localAudioPath: _recordedFilePath!,
          durationSeconds: _elapsedSeconds,
          parentCommentId: widget.parentCommentId,
        );
        if (mounted) context.go('/posts/$postId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publish failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  String _formatTimer(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_audioService?.currentUrl == _recordedFilePath) {
      _audioService?.stop();
    }
    if (_recordingSupported) {
      _audioRecordService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioService>();
    final isPreviewPlaying =
        _recordedFilePath != null &&
        audio.currentUrl == _recordedFilePath &&
        audio.isPlaying;
    final currentSeconds = _elapsedSeconds.clamp(0, _maxSeconds);
    final isReply = widget.mode == RecordingMode.reply;

    return Scaffold(
      appBar: AppBar(
        title: Text(isReply ? 'Voice Reply' : 'Voice Post'),
        leading: context.canPop()
            ? BackButton(onPressed: () => context.pop())
            : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: !_recorderReady
              ? const CircularProgressIndicator()
              : !_recordingSupported
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_off, size: 48, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        Text(
                          'Voice recording is not supported on this platform.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Use the Echo mobile app on Android or iOS to record.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : _hasRecorded
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
                              child: Text(
                                isPreviewPlaying
                                    ? 'Pause Preview'
                                    : 'Play Preview',
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isPublishing ? null : _publish,
                              child: _isPublishing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Publish'),
                            ),
                          ],
                        ),
                      ],
                    )
                  : _isRecording
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isReply ? 'Recording reply...' : 'Recording...',
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
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isReply
                                  ? 'Record a voice reply (max ${_maxSeconds}s)'
                                  : 'Record your voice post (max ${_maxSeconds}s)',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _startRecording,
                              icon: const Icon(Icons.mic),
                              label: const Text('Start recording'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }
}
