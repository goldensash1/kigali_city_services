import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(currentUserProfileProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          profileState.when(
            data: (profile) {
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(profile?.displayName ?? 'Authenticated User'),
                  subtitle: Text(profile?.email ?? 'No email'),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text(error.toString()),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              value: notificationsEnabled,
              onChanged: (value) {
                ref.read(notificationsEnabledProvider.notifier).state = value;
              },
              title: const Text('Location-based notifications'),
              subtitle: const Text('Local simulation only'),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
