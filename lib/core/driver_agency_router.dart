import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/agency/auth/agency_login_screen.dart';
import '../features/agency/dashboard/agency_dashboard.dart';
import '../features/driver/dashboard/driver_dashboard.dart';
import '../features/splash/splash_screen.dart';
import 'firestore_service.dart';

/// GoRouter for the standalone Driver & Agency mobile app.
/// Entry: lib/main_driver_agency.dart
/// Run:   flutter run -t lib/main_driver_agency.dart
final driverAgencyRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(
        onNavigateReady: _resolveDriverAgencyRoute,
      ),
    ),
  ],
);

/// After the splash animation, check auth state and route accordingly:
///   - Driver already logged in   → DriverDashboard
///   - Agency already logged in   → AgencyDashboard
///   - Not logged in              → AgencyLoginScreen (has "I'm a Driver" switch)
Future<void> _resolveDriverAgencyRoute(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    _go(context, const AgencyLoginScreen());
    return;
  }

  final service = FirestoreService();

  final driver = await service.getDriverById(user.uid);
  if (driver != null) {
    if (!context.mounted) return;
    _go(context, DriverDashboard(driver: driver));
    return;
  }

  final agency = await service.getAgencyById(user.uid);
  if (agency != null) {
    if (!context.mounted) return;
    _go(context, AgencyDashboard(agency: agency));
    return;
  }

  if (!context.mounted) return;
  _go(context, const AgencyLoginScreen());
}

void _go(BuildContext context, Widget screen) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}
