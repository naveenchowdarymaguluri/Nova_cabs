import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class PricingManagementScreen extends StatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  State<PricingManagementScreen> createState() => _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  final Map<String, double> _prices = {
    '4-Seater': 12.0,
    '7-Seater': 18.0,
    '13-Seater': 25.0,
  };

  bool _includeTolls = false;
  bool _includeDriverAllowance = false;
  double _tollAmount = 150.0;
  double _driverAllowance = 300.0;

  // Fare calculator
  final _distanceCtrl = TextEditingController(text: '100');
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  String _calcCabType = '4-Seater';
  double? _estimatedFare;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPricePerKmSection(),
            const SizedBox(height: 24),
            _buildAdditionalCharges(),
            const SizedBox(height: 24),
            _buildFareCalculator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPricePerKmSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Per KM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Set base pricing for each cab type', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 16),
        ..._prices.entries.map((entry) => _buildPriceCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildPriceCard(String cabType, double price) {
    final icons = {'4-Seater': Icons.directions_car, '7-Seater': Icons.airport_shuttle, '13-Seater': Icons.bus_alert};
    final colors = {'4-Seater': Colors.blue, '7-Seater': Colors.orange, '13-Seater': Colors.purple};
    final color = colors[cabType]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icons[cabType], color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cabType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  'Example: 100 KM × ₹${price.toStringAsFixed(0)} = ₹${(100 * price).toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: price.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: '₹',
                suffixText: '/km',
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (v) {
                final val = double.tryParse(v);
                if (val != null) setState(() => _prices[cabType] = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalCharges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Additional Charges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Optional charges added to the base fare', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Switch(
                    value: _includeTolls,
                    activeThumbColor: AppTheme.primaryColor,
                    onChanged: (val) => setState(() => _includeTolls = val),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Include Toll Charges', style: TextStyle(fontWeight: FontWeight.w500))),
                  if (_includeTolls)
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        initialValue: _tollAmount.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          prefixText: '₹',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) {
                          final val = double.tryParse(v);
                          if (val != null) setState(() => _tollAmount = val);
                        },
                      ),
                    ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Switch(
                    value: _includeDriverAllowance,
                    activeThumbColor: AppTheme.primaryColor,
                    onChanged: (val) => setState(() => _includeDriverAllowance = val),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Driver Allowance', style: TextStyle(fontWeight: FontWeight.w500))),
                  if (_includeDriverAllowance)
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        initialValue: _driverAllowance.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          prefixText: '₹',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) {
                          final val = double.tryParse(v);
                          if (val != null) setState(() => _driverAllowance = val);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pricing updated successfully!'), backgroundColor: Colors.green),
            );
          },
          child: const Text('Save Pricing Configuration'),
        ),
      ],
    );
  }

  Widget _buildFareCalculator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fare Calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Estimate fare for a trip', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            children: [
              TextField(
                controller: _fromCtrl,
                decoration: const InputDecoration(
                  labelText: 'From Location',
                  prefixIcon: Icon(Icons.my_location, color: Colors.green),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _toCtrl,
                decoration: const InputDecoration(
                  labelText: 'To Location',
                  prefixIcon: Icon(Icons.location_on, color: Colors.red),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _distanceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Distance (KM)',
                        prefixIcon: Icon(Icons.route),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _calcCabType,
                      decoration: const InputDecoration(labelText: 'Cab Type'),
                      items: _prices.keys
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _calcCabType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateFare,
                child: const Text('Calculate Fare'),
              ),
              if (_estimatedFare != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Text('Fare Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildFareRow('Base Fare',
                          '₹${(double.tryParse(_distanceCtrl.text) ?? 0 * _prices[_calcCabType]!).toStringAsFixed(0)}'),
                      if (_includeTolls) _buildFareRow('Toll Charges', '₹${_tollAmount.toStringAsFixed(0)}'),
                      if (_includeDriverAllowance)
                        _buildFareRow('Driver Allowance', '₹${_driverAllowance.toStringAsFixed(0)}'),
                      const Divider(),
                      _buildFareRow('Total Fare', '₹${_estimatedFare!.toStringAsFixed(0)}', isBold: true),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFareRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 13,
              color: isBold ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _calculateFare() {
    final distance = double.tryParse(_distanceCtrl.text) ?? 0;
    final pricePerKm = _prices[_calcCabType] ?? 0;
    double fare = distance * pricePerKm;
    if (_includeTolls) fare += _tollAmount;
    if (_includeDriverAllowance) fare += _driverAllowance;
    setState(() => _estimatedFare = fare);
  }
}
