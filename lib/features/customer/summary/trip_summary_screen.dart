import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../booking/payment_screen.dart';
import '../rating/rating_screen.dart';

class TripSummaryScreen extends StatefulWidget {
  final TripRequest trip;
  final DriverModel driver;

  const TripSummaryScreen({
    super.key,
    required this.trip,
    required this.driver,
  });

  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen> {
  bool _isFinalPaid = false;

  @override
  Widget build(BuildContext context) {
    final remainingAmount = (widget.trip.finalFare ?? widget.trip.estimatedFare) - widget.trip.advancePaid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trip Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 32),
            _buildTripStats(),
            const SizedBox(height: 24),
            _buildRouteSummary(),
            const SizedBox(height: 24),
            _buildFareBreakdown(remainingAmount),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildActionFooter(remainingAmount),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        ),
        const SizedBox(height: 16),
        const Text('Trip Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Thank you for riding with Nova Cabs', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildTripStats() {
    return Row(
      children: [
        _buildStatItem('Distance', '${widget.trip.actualDistance ?? widget.trip.estimatedDistance} KM'),
        _buildStatItem('Duration', '45 Mins'),
        _buildStatItem('Time', '10:45 AM'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildLocationRow(Icons.my_location, 'Pickup', widget.trip.pickupLocation, Colors.green),
          const SizedBox(height: 12),
          _buildLocationRow(
            widget.trip.rentalPackage != null ? Icons.timer_outlined : Icons.location_on, 
            widget.trip.rentalPackage != null ? 'Package' : 'Drop', 
            widget.trip.rentalPackage ?? widget.trip.dropLocation, 
            widget.trip.rentalPackage != null ? Colors.orange : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFareBreakdown(double remaining) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fare Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFareRow('Base Fare', '₹100'),
        _buildFareRow(
          widget.trip.rentalPackage != null ? 'Package Fare' : 'Distance Fare (${widget.trip.actualDistance} KM)', 
          '₹${((widget.trip.actualDistance ?? 0) * (widget.driver.pricing?.pricePerKm ?? 12)).toInt()}',
        ),
        _buildFareRow('Toll Charges', '₹0'),
        _buildFareRow('Driver Allowance', '₹300'),
        const Divider(height: 32),
        _buildFareRow('Total Fare', '₹${widget.trip.finalFare?.toInt()}', isBold: true),
        _buildFareRow('Advance Paid', '- ₹500', color: Colors.green),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: _buildFareRow('Remaining Payment', '₹${remaining.toInt()}', isBold: true, color: AppTheme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildFareRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 15 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionFooter(double remaining) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              if (!_isFinalPaid) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      driver: widget.driver,
                      pickup: widget.trip.pickupLocation,
                      drop: widget.trip.dropLocation,
                      date: widget.trip.tripDate,
                      distance: widget.trip.actualDistance ?? widget.trip.estimatedDistance,
                      totalFare: widget.trip.finalFare ?? widget.trip.estimatedFare,
                      paymentStage: 'Final',
                      rentalPackage: widget.trip.rentalPackage,
                    ),
                  ),
                );
                if (result == true) setState(() => _isFinalPaid = true);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RatingScreen(trip: widget.trip, driver: widget.driver)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFinalPaid ? Colors.green : AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              _isFinalPaid ? 'Rate Driver' : 'Pay Remaining ₹${remaining.toInt()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
