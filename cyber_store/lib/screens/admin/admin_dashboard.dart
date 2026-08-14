import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuTile(
            title: 'Analytics',
            icon: Icons.analytics_outlined,
            onTap: () => context.push('/admin/analytics'),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            title: 'Manage Products',
            icon: Icons.inventory_2_outlined,
            onTap: () => context.push('/admin/products'),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            title: 'Update Profile',
            icon: Icons.person_outline,
            onTap: () => context.push('/admin/profile'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.grey200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.grey400),
          ],
        ),
      ),
    );
  }
}
