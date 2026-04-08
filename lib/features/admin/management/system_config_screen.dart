import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({super.key});

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> {
  bool _hotelsModuleEnabled = false;
  bool _upiEnabled = true;
  bool _novaGatewayEnabled = true;
  bool _whatsappNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  bool _emailNotificationsEnabled = false;
  bool _maintenanceMode = false;

  final List<Map<String, dynamic>> _cabTypes = [
    {'name': '4-Seater', 'capacity': 4, 'enabled': true},
    {'name': '7-Seater', 'capacity': 7, 'enabled': true},
    {'name': '13-Seater', 'capacity': 13, 'enabled': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Modules', [
              _buildToggleTile(
                'Hotels Module',
                'Enable hotel booking feature',
                Icons.hotel,
                Colors.blue,
                _hotelsModuleEnabled,
                (val) => setState(() => _hotelsModuleEnabled = val),
                badge: 'Coming Soon',
              ),
              _buildToggleTile(
                'Maintenance Mode',
                'Disable app for all users',
                Icons.build,
                Colors.red,
                _maintenanceMode,
                (val) => setState(() => _maintenanceMode = val),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection('Payment Gateway', [
              _buildToggleTile(
                'UPI Payments',
                'Accept UPI payments from customers',
                Icons.qr_code,
                Colors.green,
                _upiEnabled,
                (val) => setState(() => _upiEnabled = val),
              ),
              _buildToggleTile(
                'Nova Gateway',
                'Proprietary payment gateway',
                Icons.account_balance_wallet,
                Colors.purple,
                _novaGatewayEnabled,
                (val) => setState(() => _novaGatewayEnabled = val),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection('Notifications', [
              _buildToggleTile(
                'WhatsApp Notifications',
                'Send booking confirmations via WhatsApp',
                Icons.message,
                Colors.green,
                _whatsappNotificationsEnabled,
                (val) => setState(() => _whatsappNotificationsEnabled = val),
              ),
              _buildToggleTile(
                'SMS Notifications',
                'Send booking updates via SMS',
                Icons.sms,
                Colors.blue,
                _smsNotificationsEnabled,
                (val) => setState(() => _smsNotificationsEnabled = val),
                badge: 'Future',
              ),
              _buildToggleTile(
                'Email Notifications',
                'Send booking receipts via email',
                Icons.email,
                Colors.orange,
                _emailNotificationsEnabled,
                (val) => setState(() => _emailNotificationsEnabled = val),
                badge: 'Future',
              ),
            ]),
            const SizedBox(height: 20),
            _buildCabTypesSection(),
            const SizedBox(height: 20),
            _buildSection('App Info', [
              _buildInfoTile('App Version', '1.0.0', Icons.info_outline),
              _buildInfoTile('Build Number', '100', Icons.build_circle_outlined),
              _buildInfoTile('Environment', 'Production', Icons.cloud),
              _buildInfoTile('API Version', 'v1.0', Icons.api),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuration saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save Configuration'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              return Column(
                children: [
                  entry.value,
                  if (entry.key < children.length - 1)
                    Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged, {
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(badge,
                            style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCabTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cab Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _addCabType,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Type'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            children: _cabTypes.asMap().entries.map((entry) {
              final cabType = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.directions_car, color: AppTheme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cabType['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('Capacity: ${cabType['capacity']} seats',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        Switch(
                          value: cabType['enabled'] as bool,
                          activeThumbColor: AppTheme.primaryColor,
                          onChanged: (val) => setState(() => cabType['enabled'] = val),
                        ),
                      ],
                    ),
                  ),
                  if (entry.key < _cabTypes.length - 1)
                    Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _addCabType() {
    final nameCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cab Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Cab Type Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Seat Capacity'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && capacityCtrl.text.isNotEmpty) {
                setState(() {
                  _cabTypes.add({
                    'name': nameCtrl.text,
                    'capacity': int.tryParse(capacityCtrl.text) ?? 0,
                    'enabled': true,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
