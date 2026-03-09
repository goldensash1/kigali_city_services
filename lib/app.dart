import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'providers/providers.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_shell.dart';

class KigaliCityServicesApp extends ConsumerWidget {
  const KigaliCityServicesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kigali City Services',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const AuthScreen();
        }
        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }
        return const HomeShell();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}
