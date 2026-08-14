import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'services/providers.dart';
import 'screens/home/home_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/products/product_detail_screen.dart';
import 'screens/products/ar_view_screen.dart';
import 'screens/products/filters_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/address_screen.dart';
import 'screens/checkout/shipping_screen.dart';
import 'screens/checkout/payment_screen.dart';
import 'screens/checkout/success_screen.dart';
import 'screens/checkout/map_picker_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/loyalty_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_product_list.dart';
import 'screens/admin/admin_product_form.dart';
import 'screens/admin/admin_profile.dart';
import 'screens/admin/admin_order_list.dart';
import 'screens/admin/admin_order_detail.dart';
import 'screens/admin/admin_analytics.dart';
import 'screens/admin/admin_coupon_list.dart';
import 'screens/orders/order_tracking_screen.dart';
import 'screens/profile/wallet_screen.dart';
import 'widgets/main_scaffold.dart';
import 'models/models.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(BuildContext context) => GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  redirect: (ctx, state) {
    final auth = ctx.read<AuthProvider>();
    const protected = ['/checkout', '/admin'];
    final needsAuth = protected.any(state.matchedLocation.startsWith);
    if (needsAuth && !auth.isSignedIn) {
      return '/login?redirect=${state.matchedLocation}';
    }

    // Redirect if email not verified
    if (auth.isSignedIn && !auth.user!.isEmailVerified && state.matchedLocation != '/verify-email') {
      return '/verify-email';
    }

    // Admin protection
    if (state.matchedLocation.startsWith('/admin')) {
      if (!auth.isSignedIn || !auth.user!.isAdmin) return '/';
    }

    return null;
  },
  routes: [
    ShellRoute(
      builder: (ctx, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/',          builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/products',  builder: (c, s) => ProductsScreen(
          category: s.uri.queryParameters['category'],
          query:    s.uri.queryParameters['q'],
        )),
        GoRoute(path: '/cart',      builder: (c, s) => const CartScreen()),
        GoRoute(path: '/profile',   builder: (c, s) => const ProfileScreen()),
        GoRoute(path: '/settings',  builder: (c, s) => const SettingsScreen()),
        GoRoute(path: '/loyalty',   builder: (c, s) => const LoyaltyScreen()),
      ],
    ),
    GoRoute(path: '/splash',            builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/about-me',          builder: (c, s) => const AboutMeScreen()),
    GoRoute(path: '/products/:id',      builder: (c, s) => ProductDetailScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/products/ar', builder: (c, s) => ARViewScreen(arModelUrl: s.extra as String)),
    GoRoute(path: '/filters',           builder: (c, s) => const FiltersScreen()),
    GoRoute(path: '/wishlist',          builder: (c, s) => const WishlistScreen()),
    GoRoute(path: '/orders',            builder: (c, s) => const OrdersScreen()),
    GoRoute(path: '/orders/:id/tracking', builder: (c, s) => OrderTrackingScreen(orderId: s.pathParameters['id']!)),
    GoRoute(path: '/wallet', builder: (c, s) => const WalletScreen()),
    GoRoute(path: '/checkout/address',  builder: (c, s) => const AddressScreen()),
    GoRoute(path: '/checkout/map',      builder: (c, s) => const MapPickerScreen()),
    GoRoute(path: '/checkout/shipping', builder: (c, s) => const ShippingScreen()),
    GoRoute(path: '/checkout/payment',  builder: (c, s) => const PaymentScreen()),
    GoRoute(path: '/checkout/success',
      builder: (c, s) => SuccessScreen(orderId: s.uri.queryParameters['id'] ?? '')),
    GoRoute(path: '/login',    builder: (c, s) => LoginScreen(redirect: s.uri.queryParameters['redirect'])),
    GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
    GoRoute(path: '/verify-email', builder: (c, s) => const EmailVerificationScreen()),

    // Admin Routes
    GoRoute(path: '/admin', builder: (c, s) => const AdminDashboard()),
    GoRoute(path: '/admin/products', builder: (c, s) => const AdminProductList()),
    GoRoute(path: '/admin/products/add', builder: (c, s) => const AdminProductForm()),
    GoRoute(path: '/admin/products/edit', builder: (c, s) => AdminProductForm(product: s.extra as ProductModel?)),
    GoRoute(path: '/admin/orders', builder: (c, s) => const AdminOrderListScreen()),
    GoRoute(path: '/admin/orders/:id', builder: (c, s) => AdminOrderDetailScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/admin/coupons', builder: (c, s) => const AdminCouponListScreen()),
    GoRoute(path: '/admin/profile', builder: (c, s) => const AdminProfileScreen()),
    GoRoute(path: '/admin/analytics', builder: (c, s) => const AdminAnalyticsScreen()),
  ],
);
