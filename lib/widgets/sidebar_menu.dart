import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  bool _isActive(String location, String prefix) {
    if (prefix == '/topics') {
      return location == '/topics' || location.startsWith('/topics/');
    }
    return location == prefix || location.startsWith('$prefix/');
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    Widget navTile({
      required IconData icon,
      required String label,
      required String route,
    }) {
      final selected = _isActive(location, route);
      return ListTile(
        leading: Icon(icon),
        title: Text(label),
        selected: selected,
        selectedTileColor: Colors.blueAccent.withValues(alpha: 0.12),
        onTap: () {
          context.go(route);
          Navigator.pop(context);
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text(
              'Echo',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          navTile(
            icon: Icons.home,
            label: 'Feed',
            route: '/feed',
          ),
          navTile(
            icon: Icons.topic,
            label: 'Topics',
            route: '/topics',
          ),
          navTile(
            icon: Icons.bookmark,
            label: 'Saved',
            route: '/saved',
          ),
          navTile(
            icon: Icons.person,
            label: 'Profile',
            route: '/profile',
          ),
        ],
      ),
    );
  }
}
