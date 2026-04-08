import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../role_selection/role_selection_screen.dart';
import '../admin/auth/admin_login_screen.dart';
import 'package:flutter/foundation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _streakController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _streakWidth;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(parent: _logoController, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _logoOpacity = CurvedAnimation(parent: _logoController, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    // Streak animation
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _streakWidth = CurvedAnimation(parent: _streakController, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = CurvedAnimation(parent: _textController, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _taglineOpacity = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(parent: _textController, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));

    // Sequence: logo → streak → text → navigate
    _logoController.forward().then((_) {
      _streakController.forward().then((_) {
        _textController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 800), _navigate);
        });
      });
    });
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) {
          final isMobile = defaultTargetPlatform == TargetPlatform.android || 
                          defaultTargetPlatform == TargetPlatform.iOS;
          return isMobile ? const RoleSelectionScreen() : const AdminLoginScreen();
        },
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _streakController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B6E), Color(0xFF1A237E), Color(0xFF283593)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -60,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.025),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon with scale + fade animation
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, __) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: AppTheme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                              'assets/icons/app_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Animated streak line
                  AnimatedBuilder(
                    animation: _streakController,
                    builder: (_, __) => ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _streakWidth.value,
                        child: Container(
                          width: 180,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, AppTheme.accentColor, Colors.transparent],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // App name + tagline
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, __) => SlideTransition(
                      position: _textSlide,
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Nova',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Cabs',
                                    style: TextStyle(
                                      color: AppTheme.accentColor,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Opacity(
                              opacity: _taglineOpacity.value,
                              child: Text(
                                'Your ride, your way',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 15,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom version text
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (_, __) => Opacity(
                  opacity: _taglineOpacity.value,
                  child: Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
