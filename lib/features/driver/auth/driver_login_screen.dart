import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_mock_data.dart';
import '../../../core/extended_models.dart';
import '../../shared/otp_screen.dart';
import '../dashboard/driver_dashboard.dart';
import '../registration/driver_registration_screen.dart';

/// Driver Login Screen — Mobile OTP based
class DriverLoginScreen extends ConsumerStatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  ConsumerState<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends ConsumerState<DriverLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
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
          role: 'Driver',
          onVerified: () => _onOtpVerified('+91 $phone'),
        ),
      ),
    );
  }

  void _onOtpVerified(String phone) {
    // Standardize phone for comparison
    final normalizedPhone = phone.replaceAll(RegExp(r'\s+'), '');
    
    // Check if driver exists in the system
    final drivers = ref.read(driverListProvider);
    final existing = drivers.where((d) {
      final dp = d.mobileNumber.replaceAll(RegExp(r'\s+'), '');
      return dp == normalizedPhone;
    }).firstOrNull;

    if (existing != null) {
      // Login existing driver
      ref.read(authProvider.notifier).loginAsDriver(
        name: existing.fullName,
        phone: phone,
        id: existing.id,
      );

      if (existing.status == AccountStatus.approved || existing.status == AccountStatus.active) {
        Navigator.pop(context); // Close OTP screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DriverDashboard(driver: existing)),
        );
      } else if (existing.status == AccountStatus.pendingVerification) {
        _showPendingDialog();
      } else if (existing.status == AccountStatus.rejected) {
        _showRejectedDialog(existing.adminRemarks ?? '');
      } else {
        _showPendingDialog();
      }
    } else {
      // New driver — go to registration
      Navigator.pop(context); // Close OTP screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverRegistrationScreen(phone: phone),
        ),
      );
    }
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange),
            SizedBox(width: 8),
            Text('Verification Pending'),
          ],
        ),
        content: const Text(
          'Your documents are under review by our team. You will receive an SMS once your account is approved.\n\nTypically takes 24-48 hours.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Okay, Got It'),
          ),
        ],
      ),
    );
  }

  void _showRejectedDialog(String remarks) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Application Rejected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your driver application was rejected.'),
            if (remarks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  remarks,
                  style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'Please re-register with correct documents.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverRegistrationScreen(
                    phone: _phoneController.text.trim(),
                  ),
                ),
              );
            },
            child: const Text('Re-Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
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
                      child: const Icon(Icons.drive_eta, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Driver Portal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login or register as a Nova Cabs driver',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
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
                      'We\'ll send you a one-time password to verify your identity',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    // Phone Field
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
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // New driver registration info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'New driver? Enter your number and we\'ll guide you through the registration process.',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Back to role selection
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to Role Selection'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                        ),
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
}
