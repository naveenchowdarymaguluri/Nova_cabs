import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/app_providers.dart';
import '../../core/firestore_service.dart';
import '../shared/otp_screen.dart';
import '../customer/home/home_screen.dart';
import '../driver/dashboard/driver_dashboard.dart';
import '../driver/registration/driver_registration_screen.dart';
import '../agency/dashboard/agency_dashboard.dart';

/// Single login / sign-up screen for all mobile users.
///
/// After OTP verification the app queries Firestore in order:
///   1. drivers   → DriverDashboard
///   2. agencies  → AgencyDashboard
///   3. customers → CustomerHomeScreen  (existing or newly created)
class UnifiedLoginScreen extends ConsumerStatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  ConsumerState<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends ConsumerState<UnifiedLoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _showNameField = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── OTP flow ──────────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await ref.read(otpProvider.notifier).sendOtp('+91$phone');
    if (!mounted) return;
    setState(() => _isLoading = false);

    final otpState = ref.read(otpProvider);
    if (otpState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(otpState.error!), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: '+91$phone',
          role: 'User',
          onVerified: () => _onVerified('+91$phone'),
        ),
      ),
    );
  }

  Future<void> _onVerified(String phone) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final firestore = ref.read(firestoreServiceProvider);

    debugPrint('🔐 OTP verified for $phone — checking user type...');

    // 1. Approved Driver?
    debugPrint('  → Checking if approved driver...');
    final driver = await firestore.getDriverByPhone(phone);
    if (driver != null) {
      debugPrint('  ✓ Found approved driver: ${driver.fullName} (${driver.status})');
      ref.read(authProvider.notifier).loginAsDriver(
        name: driver.fullName,
        phone: phone,
        id: driver.id,
      );
      if (!mounted) return;
      _replaceWith(DriverDashboard(driver: driver));
      return;
    }
    debugPrint('  ✗ Not an approved driver');

    // 2. Approved Agency?
    debugPrint('  → Checking if approved agency...');
    final agency = await firestore.getAgencyByPhone(phone);
    if (agency != null) {
      debugPrint('  ✓ Found approved agency: ${agency.agencyName} (${agency.status})');
      ref.read(authProvider.notifier).loginAsAgency(
        name: agency.agencyName,
        phone: phone,
        id: agency.id,
      );
      if (!mounted) return;
      _replaceWith(AgencyDashboard(agency: agency));
      return;
    }
    debugPrint('  ✗ Not an approved agency');

    // 3. Existing customer?
    debugPrint('  → Checking if existing customer...');
    final existing = await firestore.getCustomerByPhone(phone);
    if (existing != null) {
      debugPrint('  ✓ Found existing customer: ${existing.name}');
      await ref.read(authProvider.notifier).loginAsCustomer(
        name: existing.name,
        phone: phone,
        existingId: existing.id, // preserve original document ID
      );
      if (!mounted) return;
      _replaceWith(const CustomerHomeScreen());
      return;
    }
    debugPrint('  ✗ Not an existing customer — creating new account');

    // 4. New customer — auto-create profile in Firestore
    final name = _nameController.text.trim().isEmpty
        ? 'User'
        : _nameController.text.trim();
    await ref.read(authProvider.notifier).loginAsCustomer(
      name: name,
      phone: phone,
      // no existingId → new document will be created
    );
    debugPrint('  ✓ New customer registered: $name ($phone)');
    if (!mounted) return;
    _replaceWith(const CustomerHomeScreen());
  }

  void _replaceWith(Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_taxi,
                          color: AppTheme.accentColor, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome to Nova Cabs',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Login to continue — drivers & agencies\nare auto-detected after OTP',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ── Form ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your mobile number',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We\'ll send a one-time password to verify your identity',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Phone field
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        hintText: '9876543210',
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          child: Text(
                            '+91',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        counterText: '',
                      ),
                      onChanged: (v) =>
                          setState(() => _showNameField = v.length == 10),
                    ),

                    // Name field — only for new customers
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: _showNameField
                          ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: TextField(
                                controller: _nameController,
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Your Name (optional)',
                                  hintText: 'For new customers only',
                                  prefixIcon:
                                      Icon(Icons.person_outline),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 28),

                    // Get OTP button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Get OTP',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),

                    // ── Divider ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                    ),

                    // ── Register as Driver button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.drive_eta_outlined, size: 22),
                        label: const Text(
                          'Register as Individual Driver',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1565C0),
                          side: const BorderSide(
                              color: Color(0xFF1565C0), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          final phone = _phoneController.text.trim();
                          if (phone.length == 10) {
                            // Phone already entered — send OTP first, then register
                            _sendOtpForDriverRegistration(phone);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const _DriverPhoneEntryScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Already a registered driver? Just enter your\nnumber above — you\'ll be redirected automatically.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Benefits row
                    _buildBenefitsRow(),

                    const SizedBox(height: 24),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon:
                            const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Continue as Guest'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtpForDriverRegistration(String phone) async {
    setState(() => _isLoading = true);
    await ref.read(otpProvider.notifier).sendOtp('+91$phone');
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: '+91$phone',
          role: 'Driver',
          onVerified: () async {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DriverRegistrationScreen(phone: '+91$phone'),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBenefitsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _benefit(Icons.security_outlined, 'Secure OTP — no passwords needed'),
          const SizedBox(height: 8),
          _benefit(Icons.route_outlined,
              'Drivers & agencies auto-routed after login'),
          const SizedBox(height: 8),
          _benefit(Icons.history_outlined, 'Access your full booking history'),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style:
                  TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        ),
      ],
    );
  }
}

// ── Standalone phone entry for driver registration (when phone not pre-filled)

class _DriverPhoneEntryScreen extends ConsumerStatefulWidget {
  const _DriverPhoneEntryScreen();

  @override
  ConsumerState<_DriverPhoneEntryScreen> createState() =>
      _DriverPhoneEntryScreenState();
}

class _DriverPhoneEntryScreenState
    extends ConsumerState<_DriverPhoneEntryScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await ref.read(otpProvider.notifier).sendOtp('+91$phone');
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: '+91$phone',
          role: 'Driver',
          onVerified: () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DriverRegistrationScreen(phone: '+91$phone'),
              ),
              (r) => r.isFirst,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Driver Registration'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter your mobile number. We\'ll verify it via OTP and then take you through the registration form.',
                      style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Mobile Number',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              decoration: InputDecoration(
                hintText: '9876543210',
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  child: Text('+91',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontSize: 16)),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                counterText: '',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Send OTP & Continue',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
