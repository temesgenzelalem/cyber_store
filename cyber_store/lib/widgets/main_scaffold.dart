import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/providers.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import 'ai_chat_widget.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _selectedIndex(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).matchedLocation;
    if (loc.startsWith('/products')) return 1;
    if (loc.startsWith('/cart'))     return 2;
    if (loc.startsWith('/profile'))  return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx       = _selectedIndex(context);
    final cartCount = context.watch<CartProvider>().itemCount;
    final auth      = context.watch<AuthProvider>();

    return Scaffold(
      body: child,
      floatingActionButton: const AiChatWidget(),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.8),
              border: const Border(top: BorderSide(color: AppTheme.grey200, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 58,
                child: Row(
                  children: [
                    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: AppStrings.tr(context, 'Home'),
                      active: idx == 0, onTap: () => context.go('/')),
                    _NavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: AppStrings.tr(context, 'Products'),
                      active: idx == 1, onTap: () => context.go('/products')),
                    _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart,
                      label: AppStrings.tr(context, 'Cart'), active: idx == 2, badge: cartCount,
                      onTap: () => context.go('/cart')),
                    _NavItem(
                      icon: auth.isSignedIn ? Icons.person_outline : Icons.person_off_outlined,
                      activeIcon: Icons.person,
                      label: auth.isSignedIn ? AppStrings.tr(context, 'Account') : 'Sign In',
                      active: idx == 3,
                      onTap: () => auth.isSignedIn ? context.go('/profile') : context.push('/login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String   label;
  final bool     active;
  final int      badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.activeIcon,
    required this.label, required this.active, required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(clipBehavior: Clip.none, children: [
          Icon(active ? activeIcon : icon, size: 24,
            color: active ? AppTheme.black : AppTheme.grey400),
          if (badge > 0)
            Positioned(
              top: -4, right: -6,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: AppTheme.black, shape: BoxShape.circle),
                child: Center(child: Text('$badge',
                  style: const TextStyle(color: AppTheme.white, fontSize: 9, fontWeight: FontWeight.w700))),
              ),
            ),
        ]),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? AppTheme.black : AppTheme.grey400)),
      ]),
    ),
  );
}
