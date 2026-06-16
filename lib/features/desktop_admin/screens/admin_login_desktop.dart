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
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(adminLoginProvider);

    // Still checking Firestore — isCreationMode is null until resolved
    if (loginState.isCreationMode == null) {
      return Scaffold(
        backgroundColor: DesktopTheme.sidebarBg,
        body: const Center(
          child: CircularProgressIndicator(color: DesktopTheme.primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesktopTheme.sidebarBg,
      body: Row(
        children: [
          Expanded(flex: 5, child: _buildBrandPanel()),
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
                        child: loginState.isCreationMode == true
                            ? _buildCreationForm(loginState)
                            : _buildLoginForm(loginState),
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

  Widget _buildHeader({required String title, required String subtitle}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nova Cabs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DesktopTheme.textPrimary)),
          Text('Admin Portal', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
        ]),
      ]),
      const SizedBox(height: 36),
      Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: DesktopTheme.textPrimary)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(fontSize: 14, color: DesktopTheme.textMuted)),
      const SizedBox(height: 32),
    ]);
  }

  Widget _buildErrorBanner(String error) {
    return Column(children: [
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
          Expanded(child: Text(error, style: const TextStyle(color: DesktopTheme.dangerRed, fontSize: 13))),
        ]),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildEmailField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesktopTheme.textSecondary)),
      const SizedBox(height: 8),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Enter admin email',
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
    ]);
  }

  Widget _buildPasswordField({required TextEditingController ctrl, required bool obscure, required VoidCallback toggle, required String hint, VoidCallback? onSubmit}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14),
      onSubmitted: onSubmit != null ? (_) => onSubmit() : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: DesktopTheme.textMuted),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: DesktopTheme.textMuted),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: DesktopTheme.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DesktopTheme.primaryBlue, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }

  Widget _buildLoginForm(AdminLoginState loginState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHeader(title: 'Welcome back', subtitle: 'Sign in to your Super Admin account'),
      if (loginState.error != null) _buildErrorBanner(loginState.error!),
      _buildEmailField(),
      const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesktopTheme.textSecondary)),
      const SizedBox(height: 8),
      _buildPasswordField(
        ctrl: _passCtrl,
        obscure: _obscurePassword,
        toggle: () => setState(() => _obscurePassword = !_obscurePassword),
        hint: '••••••••',
        onSubmit: loginState.isLoading ? null : _doLogin,
      ),
      const SizedBox(height: 28),
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
                  Text('Access Admin Dashboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                ]),
        ),
      ),
    ]);
  }

  Widget _buildCreationForm(AdminLoginState loginState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHeader(title: 'Set up Admin Account', subtitle: 'No admin found. Create your Super Admin credentials.'),
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: DesktopTheme.accentTeal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DesktopTheme.accentTeal.withValues(alpha: 0.3)),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, size: 14, color: DesktopTheme.accentTeal),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This is a one-time setup. Your credentials will be saved securely in Firestore.',
              style: TextStyle(fontSize: 12, color: DesktopTheme.accentTeal, height: 1.4),
            ),
          ),
        ]),
      ),
      if (loginState.error != null) _buildErrorBanner(loginState.error!),
      _buildEmailField(),
      const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesktopTheme.textSecondary)),
      const SizedBox(height: 8),
      _buildPasswordField(
        ctrl: _passCtrl,
        obscure: _obscurePassword,
        toggle: () => setState(() => _obscurePassword = !_obscurePassword),
        hint: 'Create a strong password',
      ),
      const SizedBox(height: 16),
      const Text('Confirm Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesktopTheme.textSecondary)),
      const SizedBox(height: 8),
      _buildPasswordField(
        ctrl: _confirmPassCtrl,
        obscure: _obscureConfirm,
        toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
        hint: 'Re-enter password',
        onSubmit: loginState.isLoading ? null : _doCreate,
      ),
      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: loginState.isLoading ? null : _doCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesktopTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: loginState.isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Create Admin Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.check_rounded, size: 18, color: Colors.white),
                ]),
        ),
      ),
    ]);
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
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: DesktopTheme.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DesktopTheme.primaryBlue.withValues(alpha: 0.4)),
                  ),
                  child: const Text('Super Admin Portal v1.0', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 32),
                const Text(
                  'The Command\nCenter for\nNova Cabs',
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, height: 1.2, letterSpacing: -1),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Control your entire ride-hailing ecosystem from one powerful dashboard. Manage drivers, agencies, bookings, and revenue.',
                  style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 48),
                for (final feature in [
                  (Icons.people_rounded, 'Driver & Agency Management'),
                  (Icons.bar_chart_rounded, 'Real-time Analytics & Charts'),
                  (Icons.payments_rounded, 'Payment Monitoring'),
                  (Icons.notifications_rounded, 'Smart Notification System'),
                  (Icons.settings_rounded, 'Complete System Control'),
                ]) ...[
                  Row(children: [
                    Icon(feature.$1, color: Colors.white54, size: 18),
                    const SizedBox(width: 12),
                    Text(feature.$2, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ]),
                  const SizedBox(height: 12),
                ],
                const Spacer(),
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
    await ref.read(adminLoginProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
  }

  void _doCreate() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      ref.read(adminLoginProvider.notifier);
      // show inline — just trigger a state update via the notifier
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    await ref.read(adminLoginProvider.notifier).createAdmin(email, pass);
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
