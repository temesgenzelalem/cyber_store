import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 80, color: AppTheme.black),
            const SizedBox(height: 32),
            Text(
              'Verify your email address',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We have sent a verification link to ${user?.email ?? 'your email'}. Please check your inbox and click the link to verify your account.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().checkAuth();
              },
              child: const Text('I have verified'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                try {
                  await context.read<AuthProvider>().resendVerification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification email resent!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text(
                'Resend Verification Email',
                style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<AuthProvider>().signOut(),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
