import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/echo_auth_provider.dart';
import '../../widgets/sidebar_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<EchoAuthProvider>();
    final username = auth.profile?.username ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: const SidebarMenu(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(username, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
