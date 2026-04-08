import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_mock_data.dart';
import '../pricing/driver_pricing_screen.dart';

/// Driver Registration Screen — complete multi-step form
class DriverRegistrationScreen extends ConsumerStatefulWidget {
  final String phone;

  const DriverRegistrationScreen({super.key, required this.phone});

  @override
  ConsumerState<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState
    extends ConsumerState<DriverRegistrationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Personal Info
  final _nameController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _licenseController = TextEditingController();

  // Step 2: Vehicle Info
  final _vehicleNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _rcController = TextEditingController();
  final _insuranceController = TextEditingController();
  String _vehicleType = '4-Seater';
  String _fuelType = 'Petrol';

  // Step 3: Driver Type
  DriverType _driverType = DriverType.individual;
  String _selectedAgencyId = '';

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _aadhaarController.dispose();
    _licenseController.dispose();
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    _rcController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Driver Registration'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: _buildCurrentStep(),
              ),
            ),
          ),
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Personal Info', 'Vehicle Info', 'Driver Type', 'Review'];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isActive = index == _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? Colors.green
                                  : isActive
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade200,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : _stepIcon(index),
                              color: isCompleted || isActive
                                  ? Colors.white
                                  : Colors.grey.shade400,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            steps[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade500,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _stepIcon(int index) {
    switch (index) {
      case 0: return Icons.person_outline;
      case 1: return Icons.directions_car_outlined;
      case 2: return Icons.badge_outlined;
      case 3: return Icons.check_circle_outline;
      default: return Icons.circle;
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildVehicleInfoStep();
      case 2:
        return _buildDriverTypeStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information', Icons.person_outline),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'As on Aadhaar card',
          icon: Icons.person_outline,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Container(
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
                  Text(
                    widget.phone,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✓ Verified',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _aadhaarController,
          label: 'Aadhaar / ID Number',
          hint: 'XXXX-XXXX-XXXX',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.length < 12) ? 'Enter valid Aadhaar' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _licenseController,
          label: 'Driving License Number',
          hint: 'e.g. KA01 20230012345',
          icon: Icons.credit_card_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your documents will be verified by our admin team within 24-48 hours.',
                  style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vehicle Information', Icons.directions_car_outlined),
        _buildTextField(
          controller: _vehicleNumberController,
          label: 'Vehicle Number',
          hint: 'e.g. KA01AB1234',
          icon: Icons.confirmation_number_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _vehicleModelController,
          label: 'Vehicle Model',
          hint: 'e.g. Maruti Swift Dzire',
          icon: Icons.car_repair,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        // Vehicle Type
        const Text('Vehicle Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: ['4-Seater', '7-Seater', '13-Seater'].map((type) {
            final isSelected = _vehicleType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _vehicleType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Fuel Type
        const Text('Fuel Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: ['Petrol', 'Diesel', 'CNG', 'Electric'].map((fuel) {
            final isSelected = _fuelType == fuel;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _fuelType = fuel),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentColor : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppTheme.accentColor : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    fuel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _rcController,
          label: 'Vehicle RC Number',
          hint: 'Registration Certificate Number',
          icon: Icons.article_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _insuranceController,
          label: 'Insurance Number',
          hint: 'Vehicle insurance policy number',
          icon: Icons.security_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        // Vehicle images upload placeholder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade500, size: 36),
              const SizedBox(height: 8),
              Text(
                'Upload Vehicle Images',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Front, back, interior (Max 4 photos)',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera/Gallery not available in demo')),
                  );
                },
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Choose Photos'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverTypeStep() {
    final agencies = MockAgencyData.agencies
        .where((a) => a.status == AccountStatus.approved)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Driver Type', Icons.badge_outlined),
        const SizedBox(height: 8),
        // Individual Driver
        GestureDetector(
          onTap: () => setState(() => _driverType = DriverType.individual),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _driverType == DriverType.individual
                    ? AppTheme.primaryColor
                    : Colors.grey.shade200,
                width: _driverType == DriverType.individual ? 2 : 1,
              ),
              boxShadow: [
                if (_driverType == DriverType.individual)
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Colors.green, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Individual Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'I own my vehicle and work independently',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (_driverType == DriverType.individual)
                  const Icon(Icons.radio_button_checked, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
        // Agency Driver
        GestureDetector(
          onTap: () => setState(() => _driverType = DriverType.agency),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _driverType == DriverType.agency
                    ? AppTheme.primaryColor
                    : Colors.grey.shade200,
                width: _driverType == DriverType.agency ? 2 : 1,
              ),
              boxShadow: [
                if (_driverType == DriverType.agency)
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Agency Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'I work under a registered travel agency',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (_driverType == DriverType.agency)
                  const Icon(Icons.radio_button_checked, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),

        // Agency dropdown if agency driver selected
        if (_driverType == DriverType.agency) ...[
          const SizedBox(height: 20),
          const Text('Select Your Agency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedAgencyId.isEmpty ? null : _selectedAgencyId,
            hint: const Text('Choose agency'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.business_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: agencies.map((agency) {
              return DropdownMenuItem<String>(
                value: agency.id,
                child: Text(agency.agencyName),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedAgencyId = val ?? ''),
            validator: (v) {
              if (_driverType == DriverType.agency && (v == null || v.isEmpty)) {
                return 'Please select your agency';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Review & Submit', Icons.check_circle_outline),
        _buildReviewCard('Personal Info', [
          _buildReviewItem('Full Name', _nameController.text),
          _buildReviewItem('Mobile Number', widget.phone),
          _buildReviewItem('Aadhaar', _aadhaarController.text),
          _buildReviewItem('Driving License', _licenseController.text),
        ], Icons.person_outline, Colors.green),
        const SizedBox(height: 16),
        _buildReviewCard('Vehicle Info', [
          _buildReviewItem('Vehicle Number', _vehicleNumberController.text),
          _buildReviewItem('Vehicle Model', _vehicleModelController.text),
          _buildReviewItem('Vehicle Type', _vehicleType),
          _buildReviewItem('Fuel Type', _fuelType),
          _buildReviewItem('RC Number', _rcController.text),
          _buildReviewItem('Insurance', _insuranceController.text),
        ], Icons.directions_car_outlined, Colors.blue),
        const SizedBox(height: 16),
        _buildReviewCard('Driver Type', [
          _buildReviewItem('Type',
            _driverType == DriverType.individual ? 'Individual Driver' : 'Agency Driver'),
          if (_driverType == DriverType.agency && _selectedAgencyId.isNotEmpty)
            _buildReviewItem('Agency', MockAgencyData.agencies
                .firstWhere((a) => a.id == _selectedAgencyId, orElse: () => MockAgencyData.agencies.first)
                .agencyName),
        ], Icons.badge_outlined, Colors.orange),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'After submission, your account will be in PENDING_VERIFICATION status. Our admin team will verify your documents within 24-48 hours.',
                  style: TextStyle(color: Colors.amber.shade900, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String title, List<Widget> items, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Flexible(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      validator: validator,
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 50),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      _currentStep == 3 ? 'Submit Application' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 2) {
      if (_driverType == DriverType.agency && _selectedAgencyId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your agency')),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 3) {
      _submitRegistration();
    }
  }

  Future<void> _submitRegistration() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    // Create new driver
    final newDriver = DriverModel(
      id: 'D${DateTime.now().millisecondsSinceEpoch}',
      fullName: _nameController.text.trim(),
      mobileNumber: widget.phone,
      aadhaarNumber: _aadhaarController.text.trim(),
      drivingLicense: _licenseController.text.trim(),
      vehicleNumber: _vehicleNumberController.text.trim(),
      vehicleRc: _rcController.text.trim(),
      insuranceNumber: _insuranceController.text.trim(),
      vehicleType: _vehicleType,
      vehicleModel: _vehicleModelController.text.trim(),
      driverType: _driverType,
      agencyId: _driverType == DriverType.agency ? _selectedAgencyId : null,
      agencyName: _driverType == DriverType.agency
          ? MockAgencyData.agencies
              .firstWhere((a) => a.id == _selectedAgencyId, orElse: () => MockAgencyData.agencies.first)
              .agencyName
          : null,
      status: AccountStatus.pendingVerification,
      registeredAt: DateTime.now(),
    );

    ref.read(driverListProvider.notifier).addDriver(newDriver);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Application Submitted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your driver application has been submitted successfully. Our team will review your documents and approve within 24-48 hours.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'ll receive an SMS when your account is approved.',
                      style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Okay, Got It'),
            ),
          ),
        ],
      ),
    );
  }
}
