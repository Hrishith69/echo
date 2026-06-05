import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:echo_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen shows username and password fields', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    expect(find.text('Username'), findsWidgets);
    expect(find.text('Password'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
  });
}
