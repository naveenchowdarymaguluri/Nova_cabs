import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';

class AdminLoginDesktopScreen extends ConsumerStatefulWidget {
  const AdminLoginDesktopScreen({super.key});

  @override
  ConsumerState<AdminLoginDesktopScreen> createState() => _AdminLoginDesktopScreenState();
}

class _AdminLoginDesktopScreenState extends ConsumerState<AdminLoginDesktopScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController(text: 'admin@novacabs.com');
  final _passCtrl = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(adminLoginProvider);

    return Scaffold(
      backgroundColor: DesktopTheme.sidebarBg,
      body: Row(
        children: [
          // Left panel (branding)
          Expanded(
            flex: 5,
            child: _buildBrandPanel(),
          ),
          // Right panel (form)
          Expanded(
            flex: 4,
            child: Container(
              color: DesktopTheme.contentBg,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideIn,
                      child: SizedBox(
                        width: 420,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo
                            Row(children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [DesktopTheme.primaryBlue, DesktopTheme.accentTeal]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nova Cabs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DesktopTheme.textPrimary)),
                                  Text('Admin Portal', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
                                ],
                              ),
                            ]),
                            const SizedBox(height: 36),

                            const Text(
                              'Welcome back',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: DesktopTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sign in to your Super Admin account',
                              style: TextStyle(fontSize: 14, color: DesktopTheme.textMuted),
                            ),
                            const SizedBox(height: 32),

                            // Error
                            if (loginState.error != null) ...[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: DesktopTheme.dangerRed.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: DesktopTheme.dangerRed.withValues(alpha: 0.3)),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.error_outline_rounded, color: DesktopTheme.dangerRed, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(loginState.error!, style: const TextStyle(color: DesktopTheme.dangerRed, fontSize: 13))),
                                ]),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email
                            const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesktopTheme.textSecondary)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'admin@novacabs.com',
                                prefixIcon: const Icon(Icons.email_outlined, size: 18, color: DesktopTheme.textMuted),
                                filled: true,
                                fillColor: DesktopTheme.cardBg,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.border)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.border)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.primaryBlue, width: 2)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesktopTheme.textSecondary)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passCtrl,
                              obscureText: _obscurePassword,
                              style: const TextStyle(fontSize: 14),
                              onSubmitted: (_) => _doLogin(),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: DesktopTheme.textMuted),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: DesktopTheme.textMuted),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: DesktopTheme.cardBg,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.border)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.border)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.primaryBlue, width: 2)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Remember me + Forgot
                            Row(children: [
                              GestureDetector(
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                child: Row(children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: _rememberMe ? DesktopTheme.primaryBlue : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: _rememberMe ? DesktopTheme.primaryBlue : DesktopTheme.border, width: 2),
                                    ),
                                    child: _rememberMe ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Remember me', style: TextStyle(fontSize: 13, color: DesktopTheme.textSecondary)),
                                ]),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Forgot password?', style: TextStyle(fontSize: 13, color: DesktopTheme.primaryBlue)),
                              ),
                            ]),
                            const SizedBox(height: 24),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: loginState.isLoading ? null : _doLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DesktopTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: loginState.isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                                      ]),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Demo hint
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: DesktopTheme.primaryBlue.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: DesktopTheme.primaryBlue.withValues(alpha: 0.15)),
                              ),
                              child: const Row(children: [
                                Icon(Icons.info_outline_rounded, size: 14, color: DesktopTheme.primaryBlue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Demo: admin@novacabs.com / admin123\nor any email with 6+ character password',
                                    style: TextStyle(fontSize: 11, color: DesktopTheme.primaryBlue, height: 1.4),
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: DesktopTheme.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DesktopTheme.primaryBlue.withValues(alpha: 0.4)),
                  ),
                  child: const Text('🚀 Super Admin Portal v1.0', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 32),

                const Text(
                  'The Command\nCenter for\nNova Cabs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Control your entire ride-hailing ecosystem from one powerful dashboard. Manage drivers, agencies, bookings, and revenue.',
                  style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 48),

                // Feature list
                for (final feature in [
                  ('🚗', 'Driver & Agency Management'),
                  ('📊', 'Real-time Analytics & Charts'),
                  ('💳', 'Payment Monitoring'),
                  ('🔔', 'Smart Notification System'),
                  ('⚙️', 'Complete System Control'),
                ]) ...[
                  Row(children: [
                    Text(feature.$1, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Text(feature.$2, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ]),
                  const SizedBox(height: 12),
                ],

                const Spacer(),

                // Stats
                Row(children: [
                  _BrandStat('182', 'Active Drivers'),
                  const SizedBox(width: 32),
                  _BrandStat('28', 'Agencies'),
                  const SizedBox(width: 32),
                  _BrandStat('5.2K', 'Customers'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _doLogin() async {
    final success = await ref.read(adminLoginProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    // Navigation handled by parent via Consumer widget watching state
    if (!success && mounted) {
      // Error shown via state
    }
  }
}

class _BrandStat extends StatelessWidget {
  final String value, label;
  const _BrandStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
