import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';
import '../../../core/firestore_service.dart';
import '../tracking/trip_tracking_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final DriverModel driver;
  final String pickup;
  final String drop;
  final DateTime date;
  final double distance;
  final double totalFare;
  final String paymentStage; // 'Advance' or 'Final'
  final String? rentalPackage;

  const PaymentScreen({
    super.key,
    required this.driver,
    required this.pickup,
    required this.drop,
    required this.date,
    required this.distance,
    required this.totalFare,
    this.paymentStage = 'Advance',
    this.rentalPackage,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'UPI';
  bool _isProcessing = false;

  /// Advance booking charge:
  ///  • 1–20 KM  → flat ₹20
  ///  • > 20 KM  → ₹1 × estimated KMs
  double _calcAdvance(double distanceKm) {
    if (distanceKm <= 20) return 20.0;
    return distanceKm * 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final advance = _calcAdvance(widget.distance);
    final amountToPay = widget.paymentStage == 'Advance' ? advance : (widget.totalFare - advance);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.paymentStage} Payment'),
        elevation: 0,
      ),
      body: _isProcessing ? _buildProcessingState() : _buildPaymentForm(amountToPay),
      bottomNavigationBar: _isProcessing ? null : _buildPayButton(amountToPay),
    );
  }

  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text('Processing Payment...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Please do not close the app', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(double amount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountDisplay(amount),
          const SizedBox(height: 32),
          const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPaymentMethod(
            id: 'UPI',
            title: 'UPI (GPay, PhonePe, Paytm)',
            icon: Icons.qr_code_scanner,
            color: Colors.purple,
          ),
          _buildPaymentMethod(
            id: 'Card',
            title: 'Credit / Debit Card',
            icon: Icons.credit_card,
            color: Colors.blue,
          ),
          _buildPaymentMethod(
            id: 'NetBanking',
            title: 'Net Banking',
            icon: Icons.account_balance,
            color: Colors.orange,
          ),
          if (widget.paymentStage == 'Final')
            _buildPaymentMethod(
              id: 'Cash',
              title: 'Cash Payment',
              icon: Icons.payments_outlined,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            widget.paymentStage == 'Advance' ? 'Advance Payment' : 'Balance Amount',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toInt()}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod({
    required String id,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(double amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handlePaymentAction,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Pay ₹${amount.toInt()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePaymentAction() async {
    setState(() => _isProcessing = true);
    
    // Simulate payment gateway delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (widget.paymentStage == 'Advance') {
      // Create actual trip in state
      final authState = ref.read(authProvider);
      final trip = TripRequest(
        id: 'T${DateTime.now().millisecondsSinceEpoch}',
        bookingId: 'BK${DateTime.now().millisecondsSinceEpoch}',
        customerId: authState.userId ?? 'CUST001',
        customerName: authState.userName ?? 'Customer',
        customerPhone: authState.userPhone ?? '',
        pickupLocation: widget.pickup,
        dropLocation: widget.drop,
        estimatedDistance: widget.distance,
        estimatedFare: widget.totalFare,
        cabType: widget.driver.vehicleType,
        tripDate: widget.date,
        tripTime: '10:00 AM',
        status: BookingStatus.booked, // Driver needs to accept it via dashboard
        driverId: widget.driver.id,
        advancePaid: _calcAdvance(widget.distance),
        paymentStatus: PaymentStatus.success,
        createdAt: DateTime.now(),
        rentalPackage: widget.rentalPackage,
      );

      // Save explicitly to Firestore 'bookings' collection
      await ref.read(firestoreServiceProvider).saveTripRequest(trip);

      // Add to global state (optional if stream is listening, but provides immediate feedback)
      ref.read(bookingProvider.notifier).addBooking(trip);

      if (!mounted) return;
      // Show confirmation then navigate to tracking
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Payment Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Advance paid. Your confirmed trip has been sent to the driver. Track your ride below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Track My Ride', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TripTrackingScreen(trip: trip, driver: widget.driver)),
        (route) => route.isFirst,
      );
    } else {
      // Final payment completed
      Navigator.pop(context, true); // Return success to summary screen
    }
  }
}
