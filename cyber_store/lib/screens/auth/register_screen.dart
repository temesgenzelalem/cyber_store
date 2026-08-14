import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confirmCtrl= TextEditingController();
  bool  _obscure    = true;
  bool  _obscure2   = true;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _passCtrl, _confirmCtrl]) c.dispose();
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
              const Text('cyber', style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic, letterSpacing: -1)),
              const SizedBox(height: 32),
              const Text('Create account',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Join the cyber community',
                style: TextStyle(fontSize: 14, color: AppTheme.grey600)),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(children: [
                  // Full name
                  TextFormField(
                    controller:  _nameCtrl,
                    decoration:  const InputDecoration(
                      hintText:   'Full name',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 14),

                  // Email
                  TextFormField(
                    controller:   _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration:   const InputDecoration(
                      hintText:   'Email address',
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
                      (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 14),

                  // Confirm password
                  TextFormField(
                    controller:  _confirmCtrl,
                    obscureText: _obscure2,
                    decoration: InputDecoration(
                      hintText:   'Confirm password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20, color: AppTheme.grey600,
                        ),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                    validator: (v) =>
                      v != _passCtrl.text ? 'Passwords do not match' : null,
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

                  const SizedBox(height: 8),

                  // Register button
                  ElevatedButton(
                    onPressed: auth.loading ? null : _register,
                    child: auth.loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.white))
                      : const Text('Create Account'),
                  ),

                  const SizedBox(height: 24),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Already have an account? ',
                      style: TextStyle(color: AppTheme.grey600, fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.pushReplacement('/login'),
                      child: const Text('Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        )),
                    ),
                  ]),

                  const SizedBox(height: 32),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await context.read<AuthProvider>().signUp(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
    );
    if (ok && mounted) context.go('/');
  }
}
