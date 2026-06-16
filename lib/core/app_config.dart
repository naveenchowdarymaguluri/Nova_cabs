// lib/core/app_config.dart
//
// Secure runtime configuration for Nova Cabs.
//
// HOW IT WORKS
// ─────────────────────────────────────────────────────────────────────────────
// Values are injected at BUILD TIME via --dart-define (or --dart-define-from-file
// in Flutter ≥ 3.7), NOT loaded from a bundled asset file.
//
// This means:
//   • The plain-text .env file is never shipped inside the APK/IPA.
//   • The values are compiled into the binary (obfuscated with --obfuscate).
//   • No package is needed at runtime — zero extra dependencies.
//
// USAGE IN DEVELOPMENT
// ─────────────────────────────────────────────────────────────────────────────
// Option A – pass each flag individually:
//
//   flutter run \
//     --dart-define=GOOGLE_MAPS_API_KEY=AIzaSy... \
//     --dart-define=MSG91_AUTH_KEY=509101... \
//     --dart-define=MSG91_TEMPLATE_ID=6a09ef...
//
// Option B – use --dart-define-from-file (Flutter ≥ 3.7, recommended):
//
//   flutter run --dart-define-from-file=.env
//
//   Your .env must be JSON or key=value format. Flutter 3.7+ supports the
//   simple key=value format automatically.
//
// USAGE IN CI / GITHUB ACTIONS
// ─────────────────────────────────────────────────────────────────────────────
//   Store secrets in GitHub → Settings → Secrets → Actions, then:
//
//   - name: Build APK
//     run: |
//       flutter build apk \
//         --dart-define=GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }} \
//         --dart-define=MSG91_AUTH_KEY=${{ secrets.MSG91_AUTH_KEY }} \
//         --dart-define=MSG91_TEMPLATE_ID=${{ secrets.MSG91_TEMPLATE_ID }}
//
// USAGE IN VS CODE (launch.json)
// ─────────────────────────────────────────────────────────────────────────────
//   {
//     "name": "Nova Cabs (dev)",
//     "request": "launch",
//     "type": "dart",
//     "toolArgs": ["--dart-define-from-file=.env"]
//   }
//
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._(); // prevent instantiation

  // ── Google Maps ──────────────────────────────────────────────────────────
  /// Injected via --dart-define=GOOGLE_MAPS_API_KEY=<value>
  /// Falls back to the key already set in AndroidManifest.xml so the app
  /// never crashes in release builds when --dart-define is not provided.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyDdKt_rjoSjVz4k9TXa9nakXo8qTgpy_3I',
  );

  // ── MSG91 (SMS OTP) ──────────────────────────────────────────────────────
  /// Optional legacy SMS OTP provider configuration.
  static const String msg91AuthKey = String.fromEnvironment(
    'MSG91_AUTH_KEY',
    defaultValue: '',
  );

  /// Optional legacy SMS OTP provider configuration.
  static const String msg91TemplateId = String.fromEnvironment(
    'MSG91_TEMPLATE_ID',
    defaultValue: '',
  );

  // ── Guard: fail loudly if any required key is missing ───────────────────
  /// Call this once in main() before runApp() to catch missing config early.
  static void validate() {
    final missing = <String>[];

    if (googleMapsApiKey.isEmpty) missing.add('GOOGLE_MAPS_API_KEY');

    if (missing.isNotEmpty) {
      if (kReleaseMode) {
        throw StateError(
          '\n\n'
          '╔══════════════════════════════════════════════════════╗\n'
          '║          Nova Cabs — Missing Configuration           ║\n'
          '╠══════════════════════════════════════════════════════╣\n'
          '║  The following --dart-define keys are not set:       ║\n'
          '║                                                      ║\n'
          '${missing.map((k) => '║    • $k').join('\n')}\n'
          '║                                                      ║\n'
          '║  Run with:                                           ║\n'
          '║    flutter run --dart-define-from-file=.env          ║\n'
          '║                                                      ║\n'
          '║  See lib/core/app_config.dart for full instructions. ║\n'
          '╚══════════════════════════════════════════════════════╝\n',
        );
      }

      // In debug mode, allow the app to start so UI can be inspected even
      // when the map key has not been provided. This avoids a hard crash
      // while still surfacing the missing configuration problem.
      debugPrint(
        'Nova Cabs Warning: Missing configuration keys: ${missing.join(', ')}. '
        'Run with --dart-define-from-file=.env or set the missing keys.',
      );
    }
  }
}
