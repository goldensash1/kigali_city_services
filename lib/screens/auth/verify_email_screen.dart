import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24),
            const Icon(Icons.mark_email_read_outlined, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Please verify your email address before accessing the app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authController.isLoading
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).resendVerificationEmail();
                    },
              child: const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: authController.isLoading
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).reloadUser();
                    },
              child: const Text('I Verified, Refresh'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
