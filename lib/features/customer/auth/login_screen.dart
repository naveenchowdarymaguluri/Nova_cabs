import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/mock_data.dart';
import '../../../core/extended_mock_data.dart';
import '../../shared/otp_screen.dart';
import '../home/home_screen.dart';
import '../../driver/dashboard/driver_dashboard.dart';
import '../../agency/dashboard/agency_dashboard.dart';

/// Customer Login Screen — Mobile OTP based
class CustomerLoginScreen extends ConsumerStatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  ConsumerState<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends ConsumerState<CustomerLoginScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header gradient
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
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_pin_circle, color: AppTheme.accentColor, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Customer Login',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book rides, track drivers & manage trips',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Enter your mobile number',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ll send a one-time password to verify your identity',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // Phone field
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        hintText: '9876543210',
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          child: Text(
                            '+91',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        counterText: '',
                      ),
                      onChanged: (v) {
                        setState(() => _showNameField = v.length == 10);
                      },
                    ),

                    // Name field (for new customers)
                    if (_showNameField) ...[
                      const SizedBox(height: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Your Name (optional)',
                            hintText: 'What should we call you?',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Get OTP',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Benefits
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildBenefit(Icons.security, 'Secure OTP login — no passwords needed'),
                          const SizedBox(height: 8),
                          _buildBenefit(Icons.history, 'Access your full booking history'),
                          const SizedBox(height: 8),
                          _buildBenefit(Icons.track_changes, 'Track drivers in real-time'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to Role Selection'),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
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

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
      ],
    );
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await ref.read(otpProvider.notifier).sendOtp('+91 $phone');
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(
          phone: '+91 $phone',
          role: 'Customer',
          onVerified: () => _onVerified('+91 $phone'),
        ),
      ),
    );
  }

  void _onVerified(String phone) {
    // Standardize phone for comparison
    String normalize(String p) {
      String n = p.replaceAll(RegExp(r'\D'), '');
      if (n.startsWith('91') && n.length > 10) n = n.substring(2);
      return n;
    }

    final searchPhone = normalize(phone);

    // Check if phone belongs to a Driver
    final driver = MockDriverData.drivers.where((d) {
      final dp = normalize(d.mobileNumber);
      return dp == searchPhone;
    }).firstOrNull;

    if (driver != null) {
      ref.read(authProvider.notifier).loginAsDriver(
            name: driver.fullName,
            phone: phone,
            id: driver.id,
          );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => DriverDashboard(driver: driver)),
        (route) => false,
      );
      return;
    }

    // Check if phone belongs to an Agency
    final agency = MockAgencyData.agencies.where((a) {
      final ap = normalize(a.phoneNumber);
      return ap == searchPhone;
    }).firstOrNull;

    if (agency != null) {
      ref.read(authProvider.notifier).loginAsAgency(
            name: agency.agencyName,
            phone: phone,
            id: agency.id,
          );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AgencyDashboard(agency: agency)),
        (route) => false,
      );
      return;
    }

    // Existing Customer check
    final customer = MockData.customers.where((c) {
      final cp = normalize(c.phone);
      return cp == searchPhone;
    }).firstOrNull;

    if (customer != null) {
      // Login existing customer
      ref.read(authProvider.notifier).loginAsCustomer(
            name: customer.name,
            phone: phone,
          );
    } else {
      // New customer (using name from input if available)
      final name = _nameController.text.trim().isEmpty ? 'Guest User' : _nameController.text.trim();
      ref.read(authProvider.notifier).loginAsCustomer(name: name, phone: phone);
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      (route) => false,
    );
  }
}
