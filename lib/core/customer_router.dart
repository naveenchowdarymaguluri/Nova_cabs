import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/customer/home/home_screen.dart';

/// GoRouter for the standalone Customer mobile app.
/// Entry: lib/main_customer.dart
/// Run:   flutter run -t lib/main_customer.dart
final customerRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(
        onNavigateReady: _navigateToCustomerHome,
      ),
    ),
  ],
);

Future<void> _navigateToCustomerHome(BuildContext context) async {
  if (!context.mounted) return;
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const CustomerHomeScreen(),
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}
