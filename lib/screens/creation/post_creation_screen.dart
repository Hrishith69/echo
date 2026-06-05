import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostCreationScreen extends StatefulWidget {
  final String topicId;

  const PostCreationScreen({super.key, required this.topicId});

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final _subjectController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _goToRecord() {
    if (!_formKey.currentState!.validate()) return;
    final subject = Uri.encodeComponent(_subjectController.text.trim());
    context.go(
      '/record?mode=post&topicId=${widget.topicId}&subject=$subject',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Subject (required)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: 'What is this discussion about?',
                  border: OutlineInputBorder(),
                ),
                maxLength: 200,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Subject is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _goToRecord,
                icon: const Icon(Icons.mic),
                label: const Text('Record voice post'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
