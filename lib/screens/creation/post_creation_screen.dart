import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostCreationScreen extends StatelessWidget {
  const PostCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create a voice post',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/record');
              },
              icon: const Icon(Icons.mic),
              label: const Text('Record Voice Post'),
            ),
          ],
        ),
      ),
    );
  }
}
