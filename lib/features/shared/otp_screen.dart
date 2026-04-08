import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';

/// Reusable OTP verification screen for Customer / Driver / Agency
class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String role; // 'Customer', 'Driver', 'Agency'
  final VoidCallback onVerified;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.role,
    required this.onVerified,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) _canResend = true;
      });
      return _resendSeconds > 0;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  String get _enteredOtp =>
      _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_enteredOtp.length < 6) {
      _shakeController.forward(from: 0);
      return;
    }
    final notifier = ref.read(otpProvider.notifier);
    final success = await notifier.verifyOtp(_enteredOtp);
    if (success && mounted) {
      widget.onVerified();
    } else if (mounted) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Verify ${widget.role}'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sms_outlined,
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit OTP to',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.phone,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 40),

            // OTP input boxes
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeAnimation.value * (_shakeController.status == AnimationStatus.forward ? 1 : -1),
                    0,
                  ),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 48,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _focusNodes[index].hasFocus
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        width: _focusNodes[index].hasFocus ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(
                            alpha: _focusNodes[index].hasFocus ? 0.1 : 0,
                          ),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (val) {
                        setState(() {});
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (index == 5 && val.isNotEmpty) {
                          _verify();
                        }
                      },
                    ),
                  );
                }),
              ),
            ),

            if (otpState.error != null) ...[
              const SizedBox(height: 16),
              Text(
                otpState.error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: otpState.isVerifying ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: otpState.isVerifying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Didn\'t receive the OTP? ',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                _canResend
                    ? TextButton(
                        onPressed: () {
                          _startResendTimer();
                          // Clear OTP fields
                          for (final c in _controllers) {
                            c.clear();
                          }
                          _focusNodes[0].requestFocus();
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Text(
                        'Resend in ${_resendSeconds}s',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '💡 For demo, use any 6-digit OTP',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
