import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';

/// Agency Registration Screen
class AgencyRegistrationScreen extends ConsumerStatefulWidget {
  final String phone;

  const AgencyRegistrationScreen({super.key, required this.phone});

  @override
  ConsumerState<AgencyRegistrationScreen> createState() =>
      _AgencyRegistrationScreenState();
}

class _AgencyRegistrationScreenState
    extends ConsumerState<AgencyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final _agencyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Agency Registration'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: _buildStep(),
              ),
            ),
          ),
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Agency Info', 'Owner Info', 'Bank Details', 'Submit'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? Colors.green : isActive ? const Color(0xFFE65100) : Colors.grey.shade200,
                        ),
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          color: isDone || isActive ? Colors.white : Colors.grey.shade400,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(steps[i], style: TextStyle(fontSize: 9, color: isActive ? const Color(0xFFE65100) : Colors.grey)),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: isDone ? Colors.green : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildAgencyInfoStep();
      case 1:
        return _buildOwnerInfoStep();
      case 2:
        return _buildBankDetailsStep();
      default:
        return _buildReviewStep();
    }
  }

  Widget _field(TextEditingController c, String label, String hint, IconData icon, {bool required = true, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
      ),
    );
  }

  Widget _buildAgencyInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Agency Details', Icons.business, const Color(0xFFE65100)),
        _field(_agencyNameController, 'Agency Name', 'e.g. Quick Travels Pvt Ltd', Icons.business),
        _field(_addressController, 'Business Address', 'Full address with city & PIN', Icons.location_on_outlined),
        _field(_gstController, 'GST Number (Optional)', 'e.g. 29ABCDE1234F1Z5', Icons.receipt_outlined, required: false),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Agency documents (registration certificate) will be uploaded after approval.',
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Owner / Contact Info', Icons.person_outline, Colors.blue),
        _field(_ownerNameController, 'Owner Name', 'Full legal name', Icons.person_outline),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone_outlined, color: Colors.grey),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mobile Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(widget.phone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text('✓ Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        _field(_emailController, 'Business Email', 'agency@example.com', Icons.email_outlined, type: TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildBankDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Bank & Payment Info', Icons.account_balance, Colors.green),
        _field(_bankNameController, 'Bank Name', 'e.g. State Bank of India', Icons.account_balance_outlined),
        _field(_bankAccountController, 'Account Number', 'Your bank account number', Icons.numbers, type: TextInputType.number),
        _field(_ifscController, 'IFSC Code', 'e.g. SBIN0001234', Icons.code),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.green.shade700, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bank details are encrypted and stored securely. Used only for settlement payouts.',
                  style: TextStyle(color: Colors.green.shade800, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Review & Submit', Icons.check_circle_outline, Colors.teal),
        _reviewCard('Agency Details', [
          ['Agency Name', _agencyNameController.text],
          ['Address', _addressController.text],
          ['GST Number', _gstController.text.isEmpty ? 'Not provided' : _gstController.text],
        ], Icons.business, const Color(0xFFE65100)),
        const SizedBox(height: 12),
        _reviewCard('Owner Details', [
          ['Owner Name', _ownerNameController.text],
          ['Mobile Number', widget.phone],
          ['Email', _emailController.text],
        ], Icons.person_outline, Colors.blue),
        const SizedBox(height: 12),
        _reviewCard('Bank Details', [
          ['Bank Name', _bankNameController.text],
          ['Account No', _bankAccountController.text],
          ['IFSC Code', _ifscController.text],
        ], Icons.account_balance, Colors.green),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'After submission, your agency will be PENDING_APPROVAL. Admin will verify and approve within 24-72 hours.',
                  style: TextStyle(color: Colors.amber.shade900, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewCard(String title, List<List<String>> items, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item[0], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Flexible(child: Text(item[1].isEmpty ? '-' : item[1], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.end)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _next,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 50),
                backgroundColor: const Color(0xFFE65100),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(_currentStep == 3 ? 'Submit Application' : 'Next', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _next() {
    if (_currentStep < 3) {
      if (_formKey.currentState!.validate()) setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    final newAgency = AgencyModel(
      id: 'AG${DateTime.now().millisecondsSinceEpoch}',
      agencyName: _agencyNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phoneNumber: widget.phone,
      businessAddress: _addressController.text.trim(),
      gstNumber: _gstController.text.trim().isEmpty ? null : _gstController.text.trim(),
      bankDetails: '${_bankNameController.text.trim()} - ${_bankAccountController.text.trim()} | IFSC: ${_ifscController.text.trim()}',
      status: AccountStatus.pendingVerification,
      registeredAt: DateTime.now(),
      email: _emailController.text.trim(),
    );

    ref.read(agencyListProvider.notifier).addAgency(newAgency);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 80, height: 80, decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Colors.green, size: 48)),
            const SizedBox(height: 16),
            const Text('Application Submitted!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Your agency has been registered. Admin will review and approve within 24-72 hours.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); Navigator.pop(context); },
              child: const Text('Okay, Got It'),
            ),
          ),
        ],
      ),
    );
  }
}
