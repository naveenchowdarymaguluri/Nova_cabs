import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/desktop_admin/core/desktop_theme.dart';
import 'features/desktop_admin/shared/desktop_widgets.dart';
import 'features/desktop_admin/screens/admin_login_desktop.dart';
import 'features/desktop_admin/screens/desktop_admin_shell.dart';

/// Entry point for the Nova Cabs Super Admin Desktop Application.
/// This is a production-ready desktop dashboard for Windows/macOS/Linux.
/// 
/// To run:  flutter run -d windows (or macos/linux)
///
/// Features:
/// - JWT-based admin login
/// - Dashboard with real-time analytics
/// - Driver, agency, vehicle, booking, payment management
/// - Reports & analytics with fl_chart
/// - Notification management with WhatsApp templates
/// - System settings (pricing, commission, verification rules)
/// - Dark sidebar + light content desktop layout

void main() {
  runApp(
    const ProviderScope(
      child: NovaCabsDesktopAdminApp(),
    ),
  );
}

class NovaCabsDesktopAdminApp extends ConsumerWidget {
  const NovaCabsDesktopAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(adminLoginProvider);

    return MaterialApp(
      title: 'Nova Cabs — Super Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: DesktopTheme.theme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: loginState.isLoggedIn
            ? const DesktopAdminShell(key: ValueKey('shell'))
            : const AdminLoginDesktopScreen(key: ValueKey('login')),
      ),
    );
  }
}
