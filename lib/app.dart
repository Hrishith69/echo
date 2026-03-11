import 'package:flutter/material.dart';
import 'core/router.dart';
import 'core/theme.dart';

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Echo',
      theme: EchoTheme.light,
      routerConfig: echoRouter,
    );
  }
}
