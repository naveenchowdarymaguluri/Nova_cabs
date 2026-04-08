import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_mock_data.dart';
import '../../../core/extended_models.dart';
import '../../shared/otp_screen.dart';
import '../dashboard/agency_dashboard.dart';
import '../registration/agency_registration_screen.dart';

/// Agency Login Screen — Mobile OTP based
class AgencyLoginScreen extends ConsumerStatefulWidget {
  const AgencyLoginScreen({super.key});

  @override
  ConsumerState<AgencyLoginScreen> createState() => _AgencyLoginScreenState();
}

class _AgencyLoginScreenState extends ConsumerState<AgencyLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

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
                    colors: [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFF9800)],
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
                      child: const Icon(Icons.business, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Agency Portal',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login or register your travel agency',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
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
                      'We\'ll send you an OTP to verify your identity',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
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
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 16),
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
                          backgroundColor: const Color(0xFFE65100),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'New agency? Registering is simple. Enter your number and follow the steps.',
                              style: TextStyle(color: Colors.orange.shade800, fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
          role: 'Agency',
          onVerified: () => _onOtpVerified('+91 $phone'),
        ),
      ),
    );
  }

  void _onOtpVerified(String phone) {
    // Standardize phone for comparison
    final normalizedPhone = phone.replaceAll(RegExp(r'\s+'), '');
    
    // Check if agency exists in the system
    final agencies = ref.read(agencyListProvider);
    final existing = agencies.where((a) {
      final ap = a.phoneNumber.replaceAll(RegExp(r'\s+'), '');
      return ap == normalizedPhone;
    }).firstOrNull;

    if (existing != null) {
      // Login existing agency
      ref.read(authProvider.notifier).loginAsAgency(
        name: existing.agencyName,
        phone: phone,
        id: existing.id,
      );

      if (existing.status == AccountStatus.approved || existing.status == AccountStatus.active) {
        Navigator.pop(context); // Close OTP screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AgencyDashboard(agency: existing)),
        );
      } else if (existing.status == AccountStatus.pendingVerification) {
        _showPendingDialog();
      } else {
        _showPendingDialog();
      }
    } else {
      Navigator.pop(context); // Close OTP screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AgencyRegistrationScreen(phone: phone),
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
            Text('Approval Pending'),
          ],
        ),
        content: const Text(
          'Your agency is under review by our admin team. You will be notified once approved.\n\nTypically takes 24-72 hours.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }
}
