import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/app_theme.dart';
import '../customer/home/home_screen.dart';
import '../customer/auth/login_screen.dart';
import '../driver/auth/driver_login_screen.dart';
import '../agency/auth/agency_login_screen.dart';
import '../admin/auth/admin_login_screen.dart';

/// Role Selection Screen — first screen after splash.
/// Lets users pick whether they are Customer, Driver, Agency, or Admin.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Auto-redirect if not mobile
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigate(const AdminLoginScreen());
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        color: AppTheme.accentColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nova Cabs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how you\'d like to continue',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 48),

                    if (defaultTargetPlatform != TargetPlatform.windows &&
                        defaultTargetPlatform != TargetPlatform.macOS &&
                        defaultTargetPlatform != TargetPlatform.linux) ...[
                      // Role Cards
                      _buildRoleCard(
                        icon: Icons.person_pin_circle,
                        title: 'I\'m a Customer',
                        subtitle: 'Book cabs, track rides & manage trips',
                        color: const Color(0xFF4CAF50),
                        badgeText: null,
                        onTap: () => _navigate(const CustomerHomeScreen()),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        icon: Icons.drive_eta,
                        title: 'I\'m a Driver',
                        subtitle: 'Accept trips, manage earnings & profile',
                        color: const Color(0xFF2196F3),
                        badgeText: null,
                        onTap: () => _navigate(DriverLoginScreen()),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        icon: Icons.business,
                        title: 'I\'m a Travel Agency',
                        subtitle: 'Manage drivers, vehicles & bookings',
                        color: const Color(0xFFFF9800),
                        badgeText: null,
                        onTap: () => _navigate(AgencyLoginScreen()),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (defaultTargetPlatform != TargetPlatform.android &&
                        defaultTargetPlatform != TargetPlatform.iOS)
                      _buildRoleCard(
                        icon: Icons.admin_panel_settings,
                        title: 'Super Admin',
                        subtitle: 'Platform management & oversight',
                        color: const Color(0xFF9C27B0),
                        badgeText: 'Admin',
                        onTap: () => _navigate(AdminLoginScreen()),
                      ),

                    const SizedBox(height: 48),
                    // Guest access
                    if (defaultTargetPlatform != TargetPlatform.windows &&
                        defaultTargetPlatform != TargetPlatform.macOS &&
                        defaultTargetPlatform != TargetPlatform.linux)
                      GestureDetector(
                        onTap: () => _navigate(CustomerHomeScreen()),
                        child: Text(
                          'Continue as Guest →',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String? badgeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
