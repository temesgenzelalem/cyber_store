import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Info'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Avatar
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.black,
              child: Icon(Icons.person, size: 80, color: AppTheme.white),
            ),
            const SizedBox(height: 24),
            // Name
            const Text(
              'Temesgen zelalem',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Full-Stack Developer',
              style: TextStyle(fontSize: 16, color: AppTheme.grey600),
            ),
            const SizedBox(height: 32),
            // Info Cards
            _infoCard(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: '0932638178',
              onTap: () => launchUrl(Uri.parse('tel:0932638178')),
            ),
            _infoCard(
              context,
              icon: Icons.send_outlined,
              label: 'Telegram',
              value: '@Temesgen3263',
              onTap: () => launchUrl(Uri.parse('https://t.me/Temesgen3263')),
            ),
            _infoCard(
              context,
              icon: Icons.language_outlined,
              label: 'Location',
              value: 'Addis Ababa, Ethiopia',
            ),
            const SizedBox(height: 40),
            // Footer Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Passionate about building modern, pixel-perfect mobile and web applications that solve real-world problems.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.grey600, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.grey200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.black),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.grey400),
          ],
        ),
      ),
    ),
  );
}
