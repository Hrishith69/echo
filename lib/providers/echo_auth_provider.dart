import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../services/auth_service.dart';

class EchoAuthProvider extends ChangeNotifier {
  EchoAuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _onAuthChanged(_authService.currentUser);
    _authSubscription = _authService.authStateChanges.listen((data) {
      _onAuthChanged(data.session?.user);
    });
  }

  final AuthService _authService;
  late final StreamSubscription<AuthState> _authSubscription;
  bool _disposed = false;

  User? _user;
  Profile? _profile;
  bool _loading = true;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isAuthenticated => _user != null;

  AuthService get authService => _authService;

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user == null) {
      _profile = null;
    } else {
      _profile = await _authService.getCurrentProfile();
    }
    _loading = false;
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> refreshProfile() async {
    _profile = await _authService.getCurrentProfile();
    _safeNotify();
  }

  Future<void> signIn(String username, String password) async {
    await _authService.signIn(username: username, password: password);
    await refreshProfile();
  }

  Future<void> signUp(String username, String password) async {
    await _authService.signUp(username: username, password: password);
    await refreshProfile();
  }

  Future<void> signOut() => _authService.signOut();
}
