import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import 'supabase_client.dart';

class AuthService {
  AuthService({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  static const String _emailDomain = 'echo.auth';

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  String authEmailForUsername(String username) {
    return '${username.trim().toLowerCase()}@$_emailDomain';
  }

  Future<Profile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return Profile.fromJson(row);
  }

  Future<void> signUp({
    required String username,
    required String password,
  }) async {
    final trimmed = username.trim();
    if (trimmed.length < 3) {
      throw AuthException('Username must be at least 3 characters.');
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      throw AuthException('Username can only contain letters, numbers, and _.');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }

    final usernameLower = trimmed.toLowerCase();
    final existing = await _client
        .from('profiles')
        .select('id')
        .eq('username_lower', usernameLower)
        .maybeSingle();

    if (existing != null) {
      throw AuthException('Username is already taken.');
    }

    final authResponse = await _client.auth.signUp(
      email: authEmailForUsername(trimmed),
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw AuthException('Sign up failed. Please try again.');
    }

    try {
      await _client.from('profiles').insert({
        'id': user.id,
        'username': trimmed,
        'username_lower': usernameLower,
      });
    } catch (e) {
      await _client.auth.signOut();
      rethrow;
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: authEmailForUsername(username),
      password: password,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
