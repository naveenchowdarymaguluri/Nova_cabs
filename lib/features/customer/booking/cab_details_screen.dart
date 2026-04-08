import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';
import '../../../core/models.dart';
import 'booking_confirmation_screen.dart';

class CabDetailsScreen extends StatelessWidget {
  final DriverModel driver;
  final String pickup;
  final String drop;
  final DateTime date;
  final String? rentalPackage;

  const CabDetailsScreen({
    super.key,
    required this.driver,
    required this.pickup,
    required this.drop,
    required this.date,
    this.rentalPackage,
  });

  @override
  Widget build(BuildContext context) {
    const estimatedDistance = 25.0; // Mock distance
    // For rentals, we can use a higher base fare or calculate based on package if available
    final isRental = rentalPackage != null;
    final estimatedFare = isRental
        ? (driver.pricing?.baseFare ?? 0.0) * (rentalPackage!.contains('4 Hrs') ? 1.5 : (rentalPackage!.contains('8 Hrs') ? 2.5 : 3.5))
        : (driver.pricing?.estimateFare(estimatedDistance) ?? 0.0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cab Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVehicleGallery(),
            _buildDriverProfile(),
            _buildVehicleDetails(),
            _buildPricingBreakdown(estimatedDistance, estimatedFare),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildActionFooter(context, estimatedDistance, estimatedFare),
    );
  }

  Widget _buildVehicleGallery() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.white,
      child: PageView.builder(
        itemCount: driver.vehicleImages.isNotEmpty ? driver.vehicleImages.length : 1,
        itemBuilder: (context, index) {
          return Image.network(
            driver.vehicleImages.isNotEmpty 
              ? driver.vehicleImages[index] 
              : 'https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&q=80&w=600',
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildDriverProfile() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.fullName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  driver.agencyName ?? 'Professional Driver',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.rating} • ${driver.totalTrips} Trips',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Verified',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vehicle Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow('Model', driver.vehicleModel),
          _buildDetailRow('Number', driver.vehicleNumber),
          _buildDetailRow('Type', driver.vehicleType),
          _buildDetailRow('Fuel Type', 'Petrol/CNG'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown(double distance, double fare) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pricing Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow('Base Fare', '₹${driver.pricing?.baseFare.toInt() ?? 0}'),
          _buildDetailRow('Price per KM', '₹${driver.pricing?.pricePerKm.toInt() ?? 0}'),
          if (rentalPackage != null)
             _buildDetailRow('Rental Package', rentalPackage!)
          else
             _buildDetailRow('Estimated Distance', '${distance.toInt()} KM'),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Fare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '₹${fare.toInt()}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '*Tolls and taxes may apply extra',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context, double distance, double fare) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingConfirmationScreen(
                    driver: driver,
                    pickup: pickup,
                    drop: drop,
                    date: date,
                    distance: distance,
                    fare: fare,
                    rentalPackage: rentalPackage,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Proceed to Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
