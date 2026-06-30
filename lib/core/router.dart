import 'package:go_router/go_router.dart';

import '../providers/echo_auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/creation/post_creation_screen.dart';
import '../screens/creation/recording_screen.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/saved/saved_screen.dart';
import '../screens/thread/thread_screen.dart';
import '../screens/topics/topic_posts_screen.dart';
import '../screens/topics/topics_screen.dart';

GoRouter createEchoRouter(EchoAuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/feed',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoading = authProvider.isLoading;
      final isLoggedIn = authProvider.isAuthenticated;
      final onAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (isLoading) return null;
      
      // 1. If not logged in and not on login/signup, go to login
      if (!isLoggedIn && !onAuth) return '/login';
      
      // 2. If logged in and trying to see login/signup, go to feed
      if (isLoggedIn && onAuth) return '/feed';
      
      // 3. New Guard: If logged in and app is booting up completely fresh at the root path '/'
      if (isLoggedIn && state.matchedLocation == '/') return '/feed';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/topics',
        builder: (context, state) => const TopicsScreen(),
        routes: [
          GoRoute(
            path: ':topicId',
            builder: (context, state) {
              final topicId = state.pathParameters['topicId']!;
              final topicName = state.uri.queryParameters['name'] ?? 'Topic';
              return TopicPostsScreen(
                topicId: topicId,
                topicName: topicName,
              );
            },
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final topicId = state.pathParameters['topicId']!;
                  return PostCreationScreen(topicId: topicId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/posts/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return ThreadScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/record',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'post';
          final topicId = state.uri.queryParameters['topicId'];
          final postId = state.uri.queryParameters['postId'];
          final subject = state.uri.queryParameters['subject'];
          final parentCommentId = state.uri.queryParameters['parentCommentId'];
          return RecordingScreen(
            mode: mode == 'reply' ? RecordingMode.reply : RecordingMode.post,
            topicId: topicId,
            postId: postId,
            subject: subject,
            parentCommentId: parentCommentId,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedScreen(),
      ),
    ],
  );
}
