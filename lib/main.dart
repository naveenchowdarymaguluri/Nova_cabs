import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: NovaCabsApp(),
    ),
  );
}

class NovaCabsApp extends StatelessWidget {
  const NovaCabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova Cabs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
