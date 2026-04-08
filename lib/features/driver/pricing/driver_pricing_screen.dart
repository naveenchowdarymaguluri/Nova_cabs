import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';

/// Driver Pricing Configuration Screen
/// Drivers set their base fare, price per km, allowances, etc.
class DriverPricingScreen extends ConsumerStatefulWidget {
  final DriverModel driver;

  const DriverPricingScreen({super.key, required this.driver});

  @override
  ConsumerState<DriverPricingScreen> createState() => _DriverPricingScreenState();
}

class _DriverPricingScreenState extends ConsumerState<DriverPricingScreen> {
  late double _baseFare;
  late double _pricePerKm;
  late double _pricePerHour;
  late double _waitingCharges;
  late double _nightCharges;
  late double _minimumDistance;
  late double _driverAllowance;
  late String _tollPolicy;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final pricing = widget.driver.pricing;
    _baseFare = pricing?.baseFare ?? 100.0;
    _pricePerKm = pricing?.pricePerKm ?? 12.0;
    _pricePerHour = pricing?.pricePerHour ?? 200.0;
    _waitingCharges = pricing?.waitingCharges ?? 2.0;
    _nightCharges = pricing?.nightCharges ?? 150.0;
    _minimumDistance = pricing?.minimumTripDistance ?? 10.0;
    _driverAllowance = pricing?.driverAllowance ?? 300.0;
    _tollPolicy = pricing?.tollPolicy ?? 'Extra';
  }

  @override
  Widget build(BuildContext context) {
    final sampleDistance = 280.0;
    final estimatedFare = _baseFare + (sampleDistance * _pricePerKm) + _driverAllowance;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Pricing Configuration'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set Your Pricing',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transparent pricing builds trust with customers',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.price_change, color: AppTheme.accentColor, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fare Estimate Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calculate_outlined, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Sample Fare Estimate (280 km trip)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Base Fare', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('₹${_baseFare.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('280 km × ₹${_pricePerKm.toStringAsFixed(0)}/km', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('₹${(sampleDistance * _pricePerKm).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Driver Allowance', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('₹${_driverAllowance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimated Fare', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '₹${estimatedFare.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pricing sliders
            _buildPricingCard('Base Fare', Icons.home_outlined, Colors.blue, [
              _buildPriceSlider('Base Fare (₹)', _baseFare, 50, 500, (v) {
                setState(() => _baseFare = v);
              }),
            ]),
            const SizedBox(height: 16),
            _buildPricingCard('Distance Based', Icons.route, Colors.green, [
              _buildPriceSlider('Price Per KM (₹)', _pricePerKm, 5, 50, (v) {
                setState(() => _pricePerKm = v);
              }),
              _buildPriceSlider('Minimum Trip Distance (km)', _minimumDistance, 5, 50, (v) {
                setState(() => _minimumDistance = v);
              }, prefix: '', suffix: ' km'),
            ]),
            const SizedBox(height: 16),
            _buildPricingCard('Time Based', Icons.schedule, Colors.orange, [
              _buildPriceSlider('Price Per Hour (₹)', _pricePerHour, 100, 500, (v) {
                setState(() => _pricePerHour = v);
              }),
              _buildPriceSlider('Waiting Charges (₹/min)', _waitingCharges, 0.5, 10, (v) {
                setState(() => _waitingCharges = v);
              }),
            ]),
            const SizedBox(height: 16),
            _buildPricingCard('Additional Charges', Icons.add_circle_outline, Colors.purple, [
              _buildPriceSlider('Night Charges (₹)', _nightCharges, 0, 500, (v) {
                setState(() => _nightCharges = v);
              }),
              _buildPriceSlider('Driver Allowance (₹/day)', _driverAllowance, 0, 1000, (v) {
                setState(() => _driverAllowance = v);
              }),
            ]),
            const SizedBox(height: 16),
            // Toll Policy
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.toll, color: Colors.red.shade600, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Toll Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: ['Extra', 'Included', 'Not Applicable'].map((policy) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tollPolicy = policy),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _tollPolicy == policy ? AppTheme.primaryColor : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              policy,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _tollPolicy == policy ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePricing,
                icon: const Icon(Icons.save, color: Colors.white),
                label: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save Pricing',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(String title, IconData icon, Color color, List<Widget> children) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPriceSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, {String prefix = '₹', String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$prefix${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}$suffix',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: (max - min) < 10 ? ((max - min) * 10).toInt() : ((max - min) ~/ 1),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePricing() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final pricing = DriverPricing(
      baseFare: _baseFare,
      pricePerKm: _pricePerKm,
      pricePerHour: _pricePerHour,
      waitingCharges: _waitingCharges,
      nightCharges: _nightCharges,
      minimumTripDistance: _minimumDistance,
      driverAllowance: _driverAllowance,
      tollPolicy: _tollPolicy,
    );

    ref.read(driverListProvider.notifier).updatePricing(widget.driver.id, pricing);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Pricing saved successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }
}
