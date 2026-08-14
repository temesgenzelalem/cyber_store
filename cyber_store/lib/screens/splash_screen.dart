import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    // Navigate to home after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image describing the app (Tech/Cyber theme)
          Image.network(
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f?q=80&w=2070&auto=format&fit=crop',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.6),
            colorBlendMode: BlendMode.darken,
          ),
          // Logo/Title
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'cyber',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 2,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Premium Tech Store',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 14,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Indicator
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
