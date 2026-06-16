import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/sidebar_menu.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        leading: context.canPop()
            ? BackButton(onPressed: () => context.pop())
            : null,
      ),
      drawer: const SidebarMenu(),
      body: const Center(
        child: Text('Saved posts UI goes here.'),
      ),
    );
  }
}
