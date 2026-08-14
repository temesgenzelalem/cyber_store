// lib/middleware/firebase_auth_middleware.dart
//
// GoRouter redirect already handles auth guarding in router.dart.
// This file provides a reusable guard helper and a FirebaseAuth
// stream-aware redirect callback you can plug into GoRouter directly.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

/// Returns a GoRouter redirect callback that protects [protectedPaths].
/// If the user is not signed in and navigates to a protected path,
/// they are redirected to [loginPath] with a `redirect` query param.
GoRouterRedirect buildAuthGuard({
  required List<String> protectedPaths,
  String loginPath = '/login',
}) {
  return (context, state) {
    final user     = FirebaseAuth.instance.currentUser;
    final location = state.matchedLocation;
    final isProtected = protectedPaths.any(location.startsWith);

    if (isProtected && user == null) {
      return '$loginPath?redirect=$location';
    }
    return null;
  };
}
