import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 18),
              const Text(
                'Kigali City Services',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text('Sign in or create an account to continue'),
              const SizedBox(height: 24),
              TabBar(
                controller: _tabController,
                tabs: const <Tab>[Tab(text: 'Login'), Tab(text: 'Sign Up')],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _AuthForm(
                      fields: <Widget>[
                        TextField(
                          controller: _signInEmailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _signInPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .signIn(
                                        email: _signInEmailController.text.trim(),
                                        password: _signInPasswordController.text.trim(),
                                      );
                                },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                    _AuthForm(
                      fields: <Widget>[
                        TextField(
                          controller: _signUpNameController,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _signUpEmailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _signUpPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .signUp(
                                        email: _signUpEmailController.text.trim(),
                                        password: _signUpPasswordController.text.trim(),
                                        displayName: _signUpNameController.text.trim(),
                                      );
                                },
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (authState.isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({required this.fields});

  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: fields,
      ),
    );
  }
}
