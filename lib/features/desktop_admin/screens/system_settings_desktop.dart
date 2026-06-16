import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firestore_service.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';

class SystemSettingsDesktopScreen extends ConsumerStatefulWidget {
  const SystemSettingsDesktopScreen({super.key});

  @override
  ConsumerState<SystemSettingsDesktopScreen> createState() => _SystemSettingsDesktopScreenState();
}

class _SystemSettingsDesktopScreenState extends ConsumerState<SystemSettingsDesktopScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _cabTypes = [
    {'icon': Icons.airline_seat_recline_normal, 'type': '4-Seater', 'description': 'Standard sedan for 1-4 passengers', 'baseFare': 100.0, 'perKm': 12.0, 'active': true},
    {'icon': Icons.directions_car_rounded, 'type': '7-Seater', 'description': 'SUV / MUV for 5-7 passengers', 'baseFare': 150.0, 'perKm': 18.0, 'active': true},
    {'icon': Icons.airport_shuttle_rounded, 'type': '13-Seater', 'description': 'Tempo traveller for 8-13 passengers', 'baseFare': 250.0, 'perKm': 25.0, 'active': true},
  ];

  double _commissionPct = 30.0;
  bool _autoApproveDrivers = false;
  bool _autoApproveAgencies = false;
  bool _maintenanceMode = false;
  bool _allowCashPayments = true;
  bool _allowUPIPayments = true;
  bool _smsNotifications = true;
  bool _emailNotifications = true;
  bool _whatsappNotifications = true;

  // Admin account tab state
  String? _currentEmail;
  String? _currentPassword;
  bool _loadingCredentials = true;
  bool _showStoredPassword = false;

  final _newEmailCtrl = TextEditingController();
  final _emailCurrentPassCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _emailUpdating = false;
  bool _passUpdating = false;
  String? _emailError;
  String? _emailSuccess;
  String? _passError;
  String? _passSuccess;

  bool _obscureEmailPass = true;
  bool _obscureCurrentPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  final _tabs = ['Cab Types', 'Pricing', 'Commission', 'Verification', 'Payment Gateway', 'Notifications', 'Admin Account'];

  @override
  void initState() {
    super.initState();
    _loadCurrentEmail();
  }

  Future<void> _loadCurrentEmail() async {
    try {
      final creds = await ref.read(firestoreServiceProvider).getSuperAdminCredentials();
      if (mounted) setState(() {
        _currentEmail = creds['email'];
        _currentPassword = creds['password'];
        _loadingCredentials = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loadingCredentials = false; });
    }
  }

  @override
  void dispose() {
    _newEmailCtrl.dispose();
    _emailCurrentPassCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'System Settings',
            subtitle: 'Configure platform-wide settings and rules',
            action: _selectedTab != 6
                ? PrimaryButton(label: 'Save All Settings', icon: Icons.save_rounded, onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!'), backgroundColor: DesktopTheme.successGreen));
                  })
                : null,
          ),
          const SizedBox(height: 20),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.asMap().entries.map((e) {
                final isActive = e.key == _selectedTab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = e.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? DesktopTheme.primaryBlue : DesktopTheme.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isActive ? DesktopTheme.primaryBlue : DesktopTheme.border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (e.key == 6) ...[
                        Icon(Icons.manage_accounts_rounded, size: 14, color: isActive ? Colors.white : DesktopTheme.textMuted),
                        const SizedBox(width: 6),
                      ],
                      Text(e.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : DesktopTheme.textSecondary)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: return _buildCabTypesTab();
      case 1: return _buildPricingTab();
      case 2: return _buildCommissionTab();
      case 3: return _buildVerificationTab();
      case 4: return _buildPaymentGatewayTab();
      case 5: return _buildNotificationsTab();
      case 6: return _buildAdminAccountTab();
      default: return const SizedBox.shrink();
    }
  }

  // ─── Admin Account Tab ─────────────────────────────────────────────────────

  Widget _buildAdminAccountTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current account info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DesktopTheme.primaryBlue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DesktopTheme.primaryBlue.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: DesktopTheme.primaryBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: DesktopTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            _loadingCredentials
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: DesktopTheme.primaryBlue))
                : Expanded(
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Super Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary)),
                        const SizedBox(height: 6),
                        _credRow(Icons.email_outlined, 'Email', _currentEmail ?? '—'),
                        const SizedBox(height: 4),
                        _credRow(Icons.lock_outline_rounded, 'Password',
                          _showStoredPassword ? (_currentPassword ?? '—') : '•' * (_currentPassword?.length ?? 8)),
                      ])),
                      IconButton(
                        tooltip: _showStoredPassword ? 'Hide password' : 'Show password',
                        icon: Icon(_showStoredPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18, color: DesktopTheme.primaryBlue),
                        onPressed: () {
                          debugPrint('Current password: ${_currentPassword ?? 'N/A'}');
                          setState(() => _showStoredPassword = !_showStoredPassword);
                        },
                      ),
                    ]),
                  ),
          ]),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildUpdateEmailCard()),
            const SizedBox(width: 20),
            Expanded(child: _buildUpdatePasswordCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildUpdateEmailCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: DesktopTheme.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.email_outlined, color: DesktopTheme.accentTeal, size: 18),
          ),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Update Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary)),
            Text('Change your admin email address', style: TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
          ]),
        ]),
        const SizedBox(height: 20),

        if (_emailError != null) _buildBanner(_emailError!, isError: true),
        if (_emailSuccess != null) _buildBanner(_emailSuccess!, isError: false),

        _buildFieldLabel('New Email Address'),
        _buildTextField(ctrl: _newEmailCtrl, hint: 'Enter new email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),

        _buildFieldLabel('Current Password'),
        _buildPasswordField(ctrl: _emailCurrentPassCtrl, hint: 'Enter current password', obscure: _obscureEmailPass, onToggle: () => setState(() => _obscureEmailPass = !_obscureEmailPass)),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _emailUpdating ? null : _doUpdateEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesktopTheme.accentTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _emailUpdating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Update Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _buildUpdatePasswordCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: DesktopTheme.warningAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.lock_reset_rounded, color: DesktopTheme.warningAmber, size: 18),
          ),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Update Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary)),
            Text('Change your admin password', style: TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
          ]),
        ]),
        const SizedBox(height: 20),

        if (_passError != null) _buildBanner(_passError!, isError: true),
        if (_passSuccess != null) _buildBanner(_passSuccess!, isError: false),

        _buildFieldLabel('Current Password'),
        _buildPasswordField(ctrl: _currentPassCtrl, hint: 'Enter current password', obscure: _obscureCurrentPass, onToggle: () => setState(() => _obscureCurrentPass = !_obscureCurrentPass)),
        const SizedBox(height: 14),

        _buildFieldLabel('New Password'),
        _buildPasswordField(ctrl: _newPassCtrl, hint: 'Enter new password', obscure: _obscureNewPass, onToggle: () => setState(() => _obscureNewPass = !_obscureNewPass)),
        const SizedBox(height: 14),

        _buildFieldLabel('Confirm New Password'),
        _buildPasswordField(ctrl: _confirmPassCtrl, hint: 'Re-enter new password', obscure: _obscureConfirmPass, onToggle: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass)),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _passUpdating ? null : _doUpdatePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesktopTheme.warningAmber,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _passUpdating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Update Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _credRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 13, color: DesktopTheme.textMuted),
      const SizedBox(width: 6),
      Text('$label: ', style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesktopTheme.textPrimary)),
    ]);
  }

  Widget _buildBanner(String message, {required bool isError}) {
    final color = isError ? DesktopTheme.dangerRed : DesktopTheme.successGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: color, size: 15),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 12))),
      ]),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesktopTheme.textSecondary)),
    );
  }

  Widget _buildTextField({required TextEditingController ctrl, required String hint, required IconData icon, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 16, color: DesktopTheme.textMuted),
        filled: true,
        fillColor: DesktopTheme.contentBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.primaryBlue, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController ctrl, required String hint, required bool obscure, required VoidCallback onToggle}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 16, color: DesktopTheme.textMuted),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16, color: DesktopTheme.textMuted),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: DesktopTheme.contentBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.primaryBlue, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }

  Future<void> _doUpdateEmail() async {
    final newEmail = _newEmailCtrl.text.trim();
    final pass = _emailCurrentPassCtrl.text;

    setState(() { _emailError = null; _emailSuccess = null; });

    if (newEmail.isEmpty || pass.isEmpty) {
      setState(() => _emailError = 'All fields are required.');
      return;
    }
    if (!newEmail.contains('@')) {
      setState(() => _emailError = 'Enter a valid email address.');
      return;
    }

    setState(() => _emailUpdating = true);
    try {
      final ok = await ref.read(firestoreServiceProvider).updateSuperAdminEmail(pass, newEmail);
      if (ok) {
        _newEmailCtrl.clear();
        _emailCurrentPassCtrl.clear();
        setState(() {
          _currentEmail = newEmail;
          _emailSuccess = 'Email updated successfully.';
          _emailUpdating = false;
        });
      } else {
        setState(() { _emailError = 'Incorrect current password.'; _emailUpdating = false; });
      }
    } catch (_) {
      setState(() { _emailError = 'Failed to update email. Please try again.'; _emailUpdating = false; });
    }
  }

  Future<void> _doUpdatePassword() async {
    final current = _currentPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    setState(() { _passError = null; _passSuccess = null; });

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _passError = 'All fields are required.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _passError = 'New password must be at least 6 characters.');
      return;
    }
    if (newPass != confirm) {
      setState(() => _passError = 'New passwords do not match.');
      return;
    }

    setState(() => _passUpdating = true);
    try {
      final ok = await ref.read(firestoreServiceProvider).updateSuperAdminPassword(current, newPass);
      if (ok) {
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
        setState(() {
          _currentPassword = newPass;
          _passSuccess = 'Password updated successfully.';
          _passUpdating = false;
        });
      } else {
        setState(() { _passError = 'Incorrect current password.'; _passUpdating = false; });
      }
    } catch (_) {
      setState(() { _passError = 'Failed to update password. Please try again.'; _passUpdating = false; });
    }
  }

  // ─── Existing Tabs ─────────────────────────────────────────────────────────

  Widget _buildCabTypesTab() {
    return Column(
      children: _cabTypes.asMap().entries.map((e) {
        final i = e.key;
        final ct = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: DesktopTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(ct['icon'] as IconData, color: DesktopTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ct['type'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(ct['description'] as String, style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Base Fare', style: TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                _EditableValue(value: '₹${ct['baseFare']}', onChanged: (v) => setState(() => _cabTypes[i]['baseFare'] = double.tryParse(v) ?? ct['baseFare'])),
              ]),
              const SizedBox(width: 24),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Per km', style: TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                _EditableValue(value: '₹${ct['perKm']}/km', onChanged: (v) => setState(() => _cabTypes[i]['perKm'] = double.tryParse(v) ?? ct['perKm'])),
              ]),
              const SizedBox(width: 24),
              Column(children: [
                const Text('Active', style: TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                Switch(
                  value: ct['active'] as bool,
                  onChanged: (v) => setState(() => _cabTypes[i]['active'] = v),
                  activeThumbColor: DesktopTheme.successGreen,
                ),
              ]),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingTab() {
    final rules = [
      {'label': 'Base Fare (4-Seater)', 'value': '₹100', 'suffix': 'per booking'},
      {'label': 'Per KM Rate (4-Seater)', 'value': '₹12', 'suffix': 'per km'},
      {'label': 'Base Fare (7-Seater)', 'value': '₹150', 'suffix': 'per booking'},
      {'label': 'Per KM Rate (7-Seater)', 'value': '₹18', 'suffix': 'per km'},
      {'label': 'Base Fare (13-Seater)', 'value': '₹250', 'suffix': 'per booking'},
      {'label': 'Per KM Rate (13-Seater)', 'value': '₹25', 'suffix': 'per km'},
      {'label': 'Night Charges', 'value': '₹150', 'suffix': 'flat'},
      {'label': 'Waiting Charges', 'value': '₹2', 'suffix': 'per minute'},
      {'label': 'Driver Allowance', 'value': '₹300', 'suffix': 'per trip'},
      {'label': 'Minimum Trip km', 'value': '10', 'suffix': 'km'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Pricing Rules', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Configure platform-wide pricing parameters', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 12, childAspectRatio: 4),
          itemCount: rules.length,
          itemBuilder: (ctx, i) {
            final r = rules[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: DesktopTheme.border)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(r['suffix'] as String, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                ])),
                Text(r['value'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DesktopTheme.primaryBlue)),
              ]),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildCommissionTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Commission Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Set platform commission percentages', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Platform Commission %', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Text('${_commissionPct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: DesktopTheme.primaryBlue)),
              const SizedBox(width: 16),
              Expanded(child: Slider(
                value: _commissionPct,
                min: 5, max: 50, divisions: 45,
                activeColor: DesktopTheme.primaryBlue,
                onChanged: (v) => setState(() => _commissionPct = v),
              )),
            ]),
            const SizedBox(height: 4),
            Text('Drivers earn ${(100 - _commissionPct).toStringAsFixed(0)}% of trip fare', style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
          ])),
          const SizedBox(width: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: DesktopTheme.successGreen.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.successGreen.withValues(alpha: 0.2))),
            child: Column(children: [
              const Text('Estimated Monthly Revenue', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
              const SizedBox(height: 8),
              Text('₹${(421850 * _commissionPct / 100 / 1000).toStringAsFixed(1)}K', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: DesktopTheme.successGreen)),
              Text('at ${_commissionPct.toStringAsFixed(0)}% commission', style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _buildVerificationTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Verification Rules', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Configure auto-approval and document requirements', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
        const SizedBox(height: 20),
        _ToggleRow('Auto-approve driver registrations', 'Skip manual review and auto-approve drivers', _autoApproveDrivers, (v) => setState(() => _autoApproveDrivers = v), DesktopTheme.dangerRed),
        _ToggleRow('Auto-approve agency registrations', 'Skip manual review and auto-approve agencies', _autoApproveAgencies, (v) => setState(() => _autoApproveAgencies = v), DesktopTheme.dangerRed),
        _ToggleRow('Maintenance Mode', 'Disable all new bookings during maintenance', _maintenanceMode, (v) => setState(() => _maintenanceMode = v), DesktopTheme.warningAmber),
        const SizedBox(height: 16),
        const Text('Required Documents (Drivers)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 8, children: [
          for (final doc in ['Driving License', 'Aadhaar Card', 'Vehicle RC', 'Insurance Certificate', 'PAN Card', 'Profile Photo', 'Vehicle Photos'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: DesktopTheme.successGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: DesktopTheme.successGreen.withValues(alpha: 0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: DesktopTheme.successGreen),
                const SizedBox(width: 6),
                Text(doc, style: const TextStyle(fontSize: 12, color: DesktopTheme.successGreen, fontWeight: FontWeight.w500)),
              ]),
            ),
        ]),
      ]),
    );
  }

  Widget _buildPaymentGatewayTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Payment Gateway Configuration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Configure accepted payment methods', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
        const SizedBox(height: 20),
        _ToggleRow('UPI Payments', 'Accept UPI, Google Pay, PhonePe, etc.', _allowUPIPayments, (v) => setState(() => _allowUPIPayments = v), DesktopTheme.primaryBlue),
        _ToggleRow('Online Card Payments', 'Accept credit/debit cards via payment gateway', true, (v) {}, DesktopTheme.primaryBlue),
        _ToggleRow('Cash Payments', 'Allow customers to pay in cash to driver', _allowCashPayments, (v) => setState(() => _allowCashPayments = v), DesktopTheme.primaryBlue),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: DesktopTheme.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Razorpay Configuration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _SettingField('Merchant ID', 'rzp_live_xxxxxxxxxx'),
            _SettingField('API Key', '●●●●●●●●●●●●●●●●●●●●'),
            _SettingField('Webhook URL', 'https://api.novacabs.com/webhook'),
          ]),
        ),
      ]),
    );
  }

  Widget _buildNotificationsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Notification Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Configure platform notification channels', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
        const SizedBox(height: 20),
        _ToggleRow('SMS Notifications', 'Send booking confirmations via SMS', _smsNotifications, (v) => setState(() => _smsNotifications = v), DesktopTheme.primaryBlue),
        _ToggleRow('Email Notifications', 'Send receipts and updates via email', _emailNotifications, (v) => setState(() => _emailNotifications = v), DesktopTheme.primaryBlue),
        _ToggleRow('WhatsApp Notifications', 'Send messages via WhatsApp Business API', _whatsappNotifications, (v) => setState(() => _whatsappNotifications = v), DesktopTheme.successGreen),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: DesktopTheme.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('WhatsApp API Configuration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _SettingField('Phone Number ID', '1234567890'),
            _SettingField('Access Token', '●●●●●●●●●●●●●●●●●●●●'),
            _SettingField('Business Account ID', '9876543210'),
          ]),
        ),
      ]),
    );
  }
}

class _EditableValue extends StatelessWidget {
  final String value;
  final ValueChanged<String>? onChanged;
  const _EditableValue({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DesktopTheme.primaryBlue));
  }
}

class _ToggleRow extends StatelessWidget {
  final String label, description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _ToggleRow(this.label, this.description, this.value, this.onChanged, this.activeColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: value ? activeColor.withValues(alpha: 0.2) : DesktopTheme.border)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(description, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
        ])),
        Switch(value: value, onChanged: onChanged, activeThumbColor: activeColor),
      ]),
    );
  }
}

class _SettingField extends StatelessWidget {
  final String label, value;
  const _SettingField(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 160, child: Text(label, style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted))),
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: DesktopTheme.border)),
          child: Text(value, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
        )),
        const SizedBox(width: 8),
        const Icon(Icons.edit_rounded, size: 14, color: DesktopTheme.textMuted),
      ]),
    );
  }
}
