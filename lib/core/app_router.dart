import 'package:go_router/go_router.dart';
import '../features/admin/auth/admin_login_screen.dart';
import '../features/admin/dashboard/admin_dashboard.dart';
import '../features/role_selection/role_selection_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRoutes {
  static const splash = 'splash';
  static const roleSelection = 'roleSelection';
  static const adminLogin = 'adminLogin';
  static const adminDashboard = 'adminDashboard';

  static const splashPath = '/';
  static const roleSelectionPath = '/role-selection';
  static const adminLoginPath = '/admin-login';
  static const adminDashboardPath = '/admin-dashboard';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splashPath,
  routes: [
    GoRoute(
      name: AppRoutes.splash,
      path: AppRoutes.splashPath,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: AppRoutes.roleSelection,
      path: AppRoutes.roleSelectionPath,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      name: AppRoutes.adminLogin,
      path: AppRoutes.adminLoginPath,
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      name: AppRoutes.adminDashboard,
      path: AppRoutes.adminDashboardPath,
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
);
