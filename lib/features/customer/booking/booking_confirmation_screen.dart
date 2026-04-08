import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import 'payment_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final DriverModel driver;
  final String pickup;
  final String drop;
  final DateTime date;
  final double distance;
  final double fare;
  final String? rentalPackage;

  const BookingConfirmationScreen({
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRouteCard(),
            const SizedBox(height: 24),
            _buildTripInfo(),
            const SizedBox(height: 24),
            _buildDriverSummary(),
            const SizedBox(height: 32),
            _buildFareSummary(),
            const SizedBox(height: 48),
            _buildPolicyNote(),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(context),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildRouteRow(Icons.my_location, 'Pickup', pickup, Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(width: 2, height: 20, color: Colors.grey.shade200),
            ),
          ),
          _buildRouteRow(
            rentalPackage != null ? Icons.timer_outlined : Icons.location_on, 
            rentalPackage != null ? 'Package' : 'Drop', 
            rentalPackage ?? drop, 
            rentalPackage != null ? Colors.orange : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripInfo() {
    return Row(
      children: [
        _buildInfoItem(Icons.calendar_today, 'Date', DateFormat('dd MMM').format(date)),
        const SizedBox(width: 12),
        _buildInfoItem(Icons.access_time, 'Distance', '${distance.toInt()} KM'),
        const SizedBox(width: 12),
        _buildInfoItem(Icons.directions_car, 'Type', driver.vehicleType),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSummary() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade100,
          child: const Icon(Icons.person, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(driver.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${driver.vehicleModel} • ${driver.vehicleNumber}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Rating', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(driver.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFareSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Estimated Fare', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 4),
              Text('Inclusive of all taxes', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          Text(
            '₹${fare.toInt()}',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'A booking charge of ₹50 is required to confirm your trip. The remaining fare will be calculated based on the actual distance covered and is payable after the ride.',
              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    driver: driver,
                    pickup: pickup,
                    drop: drop,
                    date: date,
                    distance: distance,
                    totalFare: fare,
                    paymentStage: 'Advance',
                    rentalPackage: rentalPackage,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Confirm & Pay Booking Charge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
