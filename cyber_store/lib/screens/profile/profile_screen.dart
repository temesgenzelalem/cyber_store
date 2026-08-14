import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white, elevation: 0,
        title: Text(AppStrings.tr(context, 'Account'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.black)),
      ),
      body: auth.isSignedIn ? _profile(context, auth) : _guest(context),
    );
  }

  // ── Signed-in view ─────────────────────────────────────────────────────────

  Widget _profile(BuildContext context, AuthProvider auth) {
    final user = auth.user!;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Avatar + name
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Row(children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.dark,
                child: Text(
                  (user.name.isNotEmpty == true
                      ? user.name[0]
                      : user.email[0]).toUpperCase(),
                  style: const TextStyle(color: AppTheme.white, fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(user.email,
                      style: const TextStyle(fontSize: 13, color: AppTheme.grey600)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
            ]),
          ),

          const Divider(height: 1),

          if (user.isAdmin)
            _section('Administration', [
              _tile(context, Icons.admin_panel_settings_outlined, 'Admin Dashboard', () => context.push('/admin')),
            ]),

          // Menu items
          _section('My Orders', [
            _tile(context, Icons.shopping_bag_outlined, 'Order History',   () => context.push('/orders')),
            _tile(context, Icons.location_on_outlined,  'My Addresses',    () => context.push('/checkout/address')),
            _tile(context, Icons.favorite_border,       'Wishlist',        () => context.push('/wishlist')),
          ]),

          _section('Account Settings', [
            _tile(context, Icons.person_outline,        'Personal Info',   () {}),
            _tile(context, Icons.stars_outlined,        'Loyalty Program', () => context.push('/loyalty')),
            _tile(context, Icons.settings_outlined,     AppStrings.tr(context, 'Settings'), () => context.push('/settings')),
            _tile(context, Icons.notifications_outlined,'Notifications',   () {}),
            _tile(context, Icons.lock_outline,          'Change Password', () {}),
          ]),

          _section('Support', [
            _tile(context, Icons.help_outline,          'Help Center',     () {}),
            _tile(context, Icons.privacy_tip_outlined,  'Privacy Policy',  () {}),
            _tile(context, Icons.info_outline,          'About cyber',     () {}),
            _tile(context, Icons.person_pin_outlined,   'About Developer', () => context.push('/about-me')),
          ]),

          const SizedBox(height: 8),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) context.go('/');
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const CyberFooter(),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> tiles) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
        child: Text(title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.grey600)),
      ),
      Container(
        color: AppTheme.white,
        child: Column(children: tiles),
      ),
      const Divider(height: 1),
    ],
  );

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, size: 22, color: AppTheme.black),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.grey400),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      );

  // ── Guest view ─────────────────────────────────────────────────────────────

  Widget _guest(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.person_outline, size: 80, color: AppTheme.grey400),
        const SizedBox(height: 20),
        const Text('Sign in to your account',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('View orders, manage your wishlist and more',
          style: TextStyle(color: AppTheme.grey600), textAlign: TextAlign.center),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () => context.push('/login'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          child: const Text('Sign In'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.push('/register'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          child: const Text('Create Account'),
        ),
      ]),
    ),
  );
}
