import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';
import '../../../core/models.dart';
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

  @override
  Widget build(BuildContext context) {
    final amountToPay = widget.paymentStage == 'Advance' ? 50.0 : (widget.totalFare - 50.0);

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
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            widget.paymentStage == 'Advance' ? 'Booking Charge' : 'Balance Amount',
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
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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
        status: BookingStatus.driverAccepted, // Assume driver accepted immediately for flow
        driverId: widget.driver.id,
        advancePaid: 50.0,
        paymentStatus: PaymentStatus.success,
        createdAt: DateTime.now(),
        rentalPackage: widget.rentalPackage,
      );

      // Create a Booking object for the global provider
      final newBooking = Booking(
        id: trip.bookingId,
        pickupLocation: widget.pickup,
        dropLocation: widget.drop,
        date: DateFormat('dd MMM yyyy').format(widget.date),
        time: '10:00 AM',
        cab: Cab(
          id: widget.driver.id,
          model: widget.driver.vehicleModel,
          type: widget.driver.vehicleType,
          agencyName: widget.driver.agencyName ?? 'Individual',
          imageUrl: widget.driver.vehicleImages.isNotEmpty ? widget.driver.vehicleImages[0] : '',
          rating: widget.driver.rating,
          pricePerKm: widget.driver.pricing?.pricePerKm ?? 12.0,
          estimatedArrival: '8 mins',
          vehicleNumber: widget.driver.vehicleNumber,
        ),
        totalDistance: widget.distance,
        totalFare: widget.totalFare,
        status: 'Completed', // Mark as Completed for Demo to show in earnings immediately
        customerName: authState.userName ?? 'Customer',
        customerPhone: authState.userPhone ?? '',
        paymentMethod: _selectedMethod,
        paymentStatus: 'Success',
        driverId: widget.driver.id,
        rentalPackage: widget.rentalPackage,
      );

      // Add to global state
      ref.read(bookingProvider.notifier).addBooking(newBooking);

      // In a real app, this would be saved to DB. For now, we'll navigate to tracking.
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
