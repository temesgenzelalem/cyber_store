import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  final _passCtrl = TextEditingController();

  XFile? _avatar;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name);
    _emailCtrl = TextEditingController(text: user?.email);
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _avatar = picked);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.grey100,
                    backgroundImage: _avatar != null
                      ? FileImage(File(_avatar!.path)) as ImageProvider
                      : (user?.avatar != null ? NetworkImage(user!.avatar!) : null),
                    child: _avatar == null && user?.avatar == null
                      ? const Icon(Icons.person, size: 60, color: AppTheme.grey400)
                      : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.black,
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passCtrl,
              decoration: const InputDecoration(
                labelText: 'New Password (Optional)',
                hintText: 'Leave blank to keep current',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _loading ? null : _update,
              child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final updatedUser = await context.read<ApiService>().adminUpdateProfile(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text.isEmpty ? null : _passCtrl.text,
        avatarPath: _avatar?.path,
      );

      if (mounted) {
        context.read<AuthProvider>().updateProfile(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
