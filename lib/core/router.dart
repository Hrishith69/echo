import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/feed/feed_screen.dart';
import '../screens/thread/thread_screen.dart';
import '../screens/creation/post_creation_screen.dart';
import '../screens/creation/recording_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/topics/topics_screen.dart';
import '../screens/saved/saved_screen.dart';

final GoRouter echoRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FeedScreen(),
      routes: [
        GoRoute(
          path: 'thread',
          builder: (context, state) => const ThreadScreen(),
        ),
        GoRoute(
          path: 'create',
          builder: (context, state) => const PostCreationScreen(),
        ),
        GoRoute(
          path: 'record',
          builder: (context, state) => const RecordingScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'topics',
          builder: (context, state) => const TopicsScreen(),
        ),
        GoRoute(
          path: 'saved',
          builder: (context, state) => const SavedScreen(),
        ),
      ],
    ),
  ],
);
