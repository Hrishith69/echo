import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/comment.dart';
import '../../models/post.dart';
import '../../providers/echo_auth_provider.dart';
import '../../services/comment_service.dart';
import '../../services/post_service.dart';
import '../../utils/comment_tree.dart';
import '../../services/audio_service.dart';
import '../../utils/recording_platform.dart';
import '../../widgets/reply_card.dart';
import '../../widgets/waveform_player.dart';

class ThreadScreen extends StatefulWidget {
  final String postId;

  const ThreadScreen({super.key, required this.postId});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final _replyController = TextEditingController();
  final _commentService = CommentService();
  final _postService = PostService();
  late final Stream<Post?> _postStream;
  late final Stream<List<Comment>> _commentsStream;
  AudioService? _audioService;
  bool _hasText = false;
  String? _replyToCommentId;

  @override
  void initState() {
    super.initState();
    _postStream = _postService.watchPost(widget.postId);
    _commentsStream = _commentService.watchComments(widget.postId);
    _replyController.addListener(() {
      setState(() {
        _hasText = _replyController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioService ??= context.read<AudioService>();
  }

  @override
  void dispose() {
    _audioService?.stop();
    _replyController.dispose();
    super.dispose();
  }

  void _setReplyTarget(String? commentId) {
    setState(() => _replyToCommentId = commentId);
  }

  Future<void> _submitTextReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final profile = context.read<EchoAuthProvider>().profile;
    if (profile == null) return;

    try {
      await _commentService.createTextComment(
        postId: widget.postId,
        profile: profile,
        text: text,
        parentCommentId: _replyToCommentId,
      );
      _replyController.clear();
      _setReplyTarget(null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  void _startVoiceReply() {
    if (!isVoiceRecordingSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice recording is only available on Android and iOS.'),
        ),
      );
      return;
    }
    final parent = _replyToCommentId;
    final query = parent != null ? '&parentCommentId=$parent' : '';
    context.push(
      '/record?mode=reply&postId=${widget.postId}$query',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Thread'),
        elevation: 0,
        leading: context.canPop()
            ? BackButton(onPressed: () => context.pop())
            : null,
      ),
      body: StreamBuilder<Post?>(
        stream: _postStream,
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final post = postSnapshot.data;
          if (post == null) {
            return const Center(child: Text('Post not found'));
          }

          return Column(
            children: [
              if (_replyToCommentId != null)
                Material(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Expanded(child: Text('Replying to a comment')),
                        TextButton(
                          onPressed: () => _setReplyTarget(null),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.subject,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'by ${post.authorUsername}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        WaveformPlayer(
                          audioUrl: post.audioUrl,
                          knownDuration:
                              Duration(seconds: post.durationSeconds),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<List<Comment>>(
                          stream: _commentsStream,
                          builder: (context, commentSnapshot) {
                            if (commentSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              );
                            }
                            final comments = commentSnapshot.data ?? [];
                            final replyLabel = comments.isEmpty
                                ? 'Replies'
                                : 'Replies (${comments.length})';
                            final tree = buildCommentTree(comments);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  replyLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                if (tree.isEmpty)
                                  const Text('No replies yet.')
                                else
                                  Column(
                                    children: tree.map((node) {
                                      final c = node.comment;
                                      return ReplyCard(
                                        username: c.authorUsername,
                                        text: c.type == CommentType.voice
                                            ? 'Voice message'
                                            : (c.text ?? ''),
                                        level: node.depth,
                                        isVoice: c.type == CommentType.voice,
                                        duration: c.formattedDuration,
                                        durationSeconds: c.durationSeconds,
                                        audioUrl: c.audioUrl,
                                        isLast: false,
                                        onReply: () => _setReplyTarget(c.id),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 12,
            right: 12,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  decoration: InputDecoration(
                    hintText: _replyToCommentId != null
                        ? 'Reply to comment...'
                        : 'Reply...',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitTextReply(),
                ),
              ),
              const SizedBox(width: 8),
              _hasText
                  ? IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitTextReply,
                    )
                  : IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: _startVoiceReply,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
