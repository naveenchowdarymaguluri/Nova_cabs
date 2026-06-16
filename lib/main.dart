import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/app_theme.dart';
import 'core/app_config.dart'; // ← secure config, no .env asset needed
import 'core/app_router.dart';
import 'core/app_logger.dart';
import 'firebase_options.dart';

// NOTE: flutter_dotenv import removed.
// Secrets are now injected at build time via --dart-define-from-file=.env
// See lib/core/app_config.dart for full documentation.

/// FCM background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.i('[FCM] Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast in debug/profile if any required key was not injected.
  AppConfig.validate();

  // ── Critical init (blocks first frame) ────────────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // App Check is only needed on mobile (phone OTP auth).
  // Windows desktop uses email/password admin login — no App Check required.
  final isMobile = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  if (isMobile) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
    );
  }
  // ──────────────────────────────────────────────────────────────────────────

  // Show the UI immediately — all remaining setup is non-blocking.
  runApp(const ProviderScope(child: NovaCabsApp()));

  // ── Background services (run after first frame is visible) ────────────────
  _initBackgroundServices();
}

/// Runs after [runApp] so it never delays the first frame.
/// Wrapped in try-catch so no background service failure can crash the app.
Future<void> _initBackgroundServices() async {
  final isMobile = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  // ── App Check debug token (Android/iOS debug builds only) ────────────────
  if (kDebugMode && isMobile) {
    try {
      await FirebaseAppCheck.instance.getToken(true);
      AppLogger.i('[AppCheck] ✅ Token ready — phone auth should work.');
    } catch (e) {
      AppLogger.w(
        '[AppCheck] ⚠️  Token failed: $e\n'
        'Add the UUID from logcat to Firebase Console → App Check → '
        'your Android app → Manage debug tokens.',
      );
    }
  }

  // ── FCM (mobile only — Windows/desktop FCM support is limited) ───────────
  if (isDesktop) {
    AppLogger.i('[FCM] Skipped on desktop — FCM not required for admin panel.');
    return;
  }

  try {
    // Background handler must be registered before requestPermission.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;

    // Request notification permission (Android 13+ / iOS shows dialog).
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Foreground message listener.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.i(
        '[FCM] Foreground: ${message.notification?.title} — ${message.notification?.body}',
      );
      // TODO: show an in-app banner (flutter_local_notifications)
    });

    // Tap-on-notification when app is in background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.i('[FCM] Opened from background: ${message.data}');
      // TODO: deep-link based on message.data
    });

    // Log device token for development.
    final token = await messaging.getToken();
    AppLogger.i('[FCM] Device token: $token');
  } catch (e, st) {
    // Never crash the app due to FCM setup failure.
    AppLogger.e('[FCM] Setup failed (non-fatal)', error: e, stackTrace: st);
  }
}

class NovaCabsApp extends StatelessWidget {
  const NovaCabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nova Cabs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
