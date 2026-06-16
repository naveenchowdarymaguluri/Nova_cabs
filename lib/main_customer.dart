// ============================================================
// NOVA CABS — Customer Mobile App
// Entry point: flutter run -t lib/main_customer.dart
// Build APK:   flutter build apk -t lib/main_customer.dart
// ============================================================
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/app_theme.dart';
import 'core/app_config.dart';
import 'core/app_logger.dart';
import 'core/customer_router.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.i('[FCM] Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.validate();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  );

  runApp(const ProviderScope(child: NovaCabsCustomerApp()));

  _initFCM();
}

Future<void> _initFCM() async {
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((msg) {
      AppLogger.i('[FCM] Foreground: ${msg.notification?.title}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      AppLogger.i('[FCM] Opened from notification: ${msg.data}');
    });
    final token = await messaging.getToken();
    AppLogger.i('[FCM] Device token: $token');
  } catch (e, st) {
    AppLogger.e('[FCM] Setup failed (non-fatal)', error: e, stackTrace: st);
  }
}

class NovaCabsCustomerApp extends StatelessWidget {
  const NovaCabsCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nova Cabs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: customerRouter,
    );
  }
}
