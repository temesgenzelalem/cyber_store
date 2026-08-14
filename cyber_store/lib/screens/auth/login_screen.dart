import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final String? redirect;
  const LoginScreen({super.key, this.redirect});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _obscure   = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Logo
              const Text('cyber', style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic, letterSpacing: -1)),
              const SizedBox(height: 32),
              const Text('Welcome back',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Sign in to your account',
                style: TextStyle(fontSize: 14, color: AppTheme.grey600)),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(children: [
                  // Email
                  TextFormField(
                    controller:   _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration:   const InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller:  _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText:   'Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20, color: AppTheme.grey600,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                      (v == null || v.length < 6) ? 'Password must be 6+ chars' : null,
                  ),
                  const SizedBox(height: 8),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?',
                        style: TextStyle(color: AppTheme.grey600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Error
                  if (auth.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(auth.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),

                  // Sign In button
                  ElevatedButton(
                    onPressed: auth.loading ? null : _signIn,
                    child: auth.loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.white))
                      : const Text('Sign In'),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: TextStyle(
                        color: AppTheme.grey400, fontSize: 13)),
                    ),
                    const Expanded(child: Divider()),
                  ]),

                  const SizedBox(height: 24),

                  // Register
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text("Don't have an account? ",
                      style: TextStyle(color: AppTheme.grey600, fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.pushReplacement('/register'),
                      child: const Text('Register',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        )),
                    ),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await context.read<AuthProvider>().signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (ok && mounted) {
      final dest = widget.redirect ?? '/';
      context.go(dest);
    }
  }
}
