import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'providers/echo_auth_provider.dart';
import 'services/audio_service.dart';

class EchoApp extends StatefulWidget {
  const EchoApp({super.key});

  @override
  State<EchoApp> createState() => _EchoAppState();
}

class _EchoAppState extends State<EchoApp> {
  late final EchoAuthProvider _authProvider;
  late final AudioService _audioService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = EchoAuthProvider();
    _audioService = AudioService();
    _router = createEchoRouter(_authProvider);
  }

  @override
  void dispose() {
    _router.dispose();
    _audioService.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _audioService),
      ],
      child: MaterialApp.router(
        title: 'Echo',
        theme: EchoTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
