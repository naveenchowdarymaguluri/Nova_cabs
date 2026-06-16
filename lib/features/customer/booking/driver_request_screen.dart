import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import 'payment_screen.dart';

class DriverRequestScreen extends StatefulWidget {
  final DriverModel driver;
  final String pickup;
  final String drop;
  final DateTime date;
  final double distance;
  final double fare;
  final String? rentalPackage;

  const DriverRequestScreen({
    super.key,
    required this.driver,
    required this.pickup,
    required this.drop,
    required this.date,
    required this.distance,
    required this.fare,
    this.rentalPackage,
  });

  @override
  State<DriverRequestScreen> createState() => _DriverRequestScreenState();
}

class _DriverRequestScreenState extends State<DriverRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _acceptTimer;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Simulate driver acceptance after 8 seconds
    _acceptTimer = Timer(const Duration(seconds: 8), _onDriverAccepted);
  }

  void _onDriverAccepted() {
    if (!mounted || _accepted) return;
    setState(() => _accepted = true);
    _pulseController.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Driver Accepted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.driver.fullName} has accepted your booking request.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      driver: widget.driver,
                      pickup: widget.pickup,
                      drop: widget.drop,
                      date: widget.date,
                      distance: widget.distance,
                      totalFare: widget.fare,
                      rentalPackage: widget.rentalPackage,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Proceed to Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text('Are you sure you want to cancel this booking request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    _acceptTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _acceptTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Request Sent'),
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildPulsingIcon(),
                    const SizedBox(height: 32),
                    const Text(
                      'Request Sent to Driver',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Waiting for ${widget.driver.fullName} to accept your booking...',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildDriverCard(),
                    const SizedBox(height: 20),
                    _buildRouteSummary(),
                  ],
                ),
              ),
            ),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140 + (pulse * 30),
              height: 140 + (pulse * 30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.08 * (1 - pulse)),
              ),
            ),
            Container(
              width: 110 + (pulse * 10),
              height: 110 + (pulse * 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.15 * (1 - pulse)),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
              ),
              child: const Icon(Icons.local_taxi, size: 52, color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driver.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.driver.vehicleModel,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.driver.rating.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildRouteRow(Icons.my_location, Colors.green, 'From', widget.pickup),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(width: 2, height: 16, color: Colors.grey.shade300),
            ),
          ),
          _buildRouteRow(
            widget.rentalPackage != null ? Icons.timer_outlined : Icons.location_on,
            widget.rentalPackage != null ? Colors.orange : Colors.red,
            widget.rentalPackage != null ? 'Package' : 'To',
            widget.rentalPackage ?? widget.drop,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Fare', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(
                '₹${widget.fare.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              Text(value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: _cancelRequest,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Cancel Request',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
