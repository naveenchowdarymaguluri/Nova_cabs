// ============================================================
// NOVA CABS — Admin Desktop App (Windows)
// Entry point: flutter run -t lib/main_admin.dart -d windows
// Build EXE:   flutter build windows -t lib/main_admin.dart
// ============================================================
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/desktop_admin/core/desktop_theme.dart';
import 'features/desktop_admin/shared/desktop_widgets.dart';
import 'features/desktop_admin/screens/admin_login_desktop.dart';
import 'features/desktop_admin/screens/desktop_admin_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: NovaCabsAdminApp()));
}

class NovaCabsAdminApp extends ConsumerWidget {
  const NovaCabsAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(adminLoginProvider);

    return MaterialApp(
      title: 'Nova Cabs — Admin',
      debugShowCheckedModeBanner: false,
      theme: DesktopTheme.theme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: loginState.isLoggedIn
            ? const DesktopAdminShell(key: ValueKey('shell'))
            : const AdminLoginDesktopScreen(key: ValueKey('login')),
      ),
    );
  }
}
