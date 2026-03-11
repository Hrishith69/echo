import 'package:flutter/material.dart';

class ThreadScreen extends StatelessWidget {
  const ThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
      ),
      body: const Center(
        child: Text('Thread details go here.'),
      ),
    );
  }
}
