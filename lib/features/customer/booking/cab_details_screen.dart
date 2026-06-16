import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import 'booking_confirmation_screen.dart';

class CabDetailsScreen extends StatefulWidget {
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
  State<CabDetailsScreen> createState() => _CabDetailsScreenState();
}

class _CabDetailsScreenState extends State<CabDetailsScreen> {
  double _estimatedDistance = 0.0;
  double _estimatedFare = 0.0;
  bool _loadingDistance = true;

  @override
  void initState() {
    super.initState();
    _fetchDistanceAndFare();
  }

  /// Geocodes an address string to [latitude, longitude] using the device's
  /// native geocoder (no API key / billing required).
  Future<List<double>?> _geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address)
          .timeout(const Duration(seconds: 8));
      if (locations.isNotEmpty) {
        return [locations.first.latitude, locations.first.longitude];
      }
    } catch (e) {
      debugPrint('[Geocode] Failed for "$address": $e');
    }
    return null;
  }

  /// Haversine straight-line distance in km, then ×1.3 to approximate road distance.
  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c * 1.3; // ×1.3 road-distance factor
  }

  double _toRad(double deg) => deg * math.pi / 180;

  Future<void> _fetchDistanceAndFare() async {
    final isRental = widget.rentalPackage != null;

    if (isRental) {
      final hrs = _parseHours(widget.rentalPackage!);
      final multiplier = hrs <= 2 ? 1.0 : hrs <= 4 ? 1.5 : hrs <= 6 ? 2.0 : hrs <= 8 ? 2.5 : 3.5;
      if (!mounted) return;
      setState(() {
        _estimatedFare = (widget.driver.pricing?.effectiveBaseFare ?? 1.0) * multiplier;
        _loadingDistance = false;
      });
      return;
    }

    debugPrint('[Distance] Geocoding: ${widget.pickup} → ${widget.drop}');

    // Geocode both addresses in parallel
    final results = await Future.wait([
      _geocodeAddress(widget.pickup),
      _geocodeAddress(widget.drop),
    ]);

    if (!mounted) return;

    final pickupCoords = results[0];
    final dropCoords = results[1];

    if (pickupCoords != null && dropCoords != null) {
      final distanceKm = _haversineKm(
        pickupCoords[0], pickupCoords[1],
        dropCoords[0],   dropCoords[1],
      );
      final fare = widget.driver.pricing?.estimateFare(distanceKm) ??
          (1.0 + distanceKm * 5.0);
      debugPrint('[Distance] ${distanceKm.toStringAsFixed(1)} km → ₹${fare.toStringAsFixed(0)}');
      setState(() {
        _estimatedDistance = distanceKm;
        _estimatedFare = fare;
        _loadingDistance = false;
      });
    } else {
      debugPrint('[Distance] Geocoding failed — using base fare fallback');
      setState(() {
        _estimatedDistance = 0.0;
        _estimatedFare = widget.driver.pricing?.effectiveBaseFare ?? 1.0;
        _loadingDistance = false;
      });
    }
  }

  int _parseHours(String package) {
    final match = RegExp(r'(\d+)\s*Hrs').firstMatch(package);
    return match != null ? int.tryParse(match.group(1) ?? '4') ?? 4 : 4;
  }

  @override
  Widget build(BuildContext context) {
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
            _buildPricingBreakdown(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildActionFooter(context),
    );
  }

  Widget _buildVehicleGallery() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.white,
      child: PageView.builder(
        itemCount: widget.driver.vehicleImages.isNotEmpty ? widget.driver.vehicleImages.length : 1,
        itemBuilder: (context, index) {
          return Image.network(
            widget.driver.vehicleImages.isNotEmpty
                ? widget.driver.vehicleImages[index]
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driver.fullName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.driver.agencyName ?? 'Professional Driver',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.driver.rating} • ${widget.driver.totalTrips} Trips',
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vehicle Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow('Model', widget.driver.vehicleModel),
          _buildDetailRow('Type', widget.driver.vehicleType),
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

  Widget _buildPricingBreakdown() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pricing Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow('Base Fare', '₹${widget.driver.pricing?.baseFare.toInt() ?? 0}'),
          _buildDetailRow('Price per KM', '₹${widget.driver.pricing?.pricePerKm.toInt() ?? 0}'),
          if (widget.rentalPackage != null)
            _buildDetailRow('Rental Package', widget.rentalPackage!)
          else if (_loadingDistance)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estimated Distance', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            )
          else
            _buildDetailRow(
              'Estimated Distance',
              _estimatedDistance > 0 ? '${_estimatedDistance.toStringAsFixed(1)} KM' : 'N/A',
            ),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Fare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _loadingDistance
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      '₹${_estimatedFare.toInt()}',
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

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _loadingDistance
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmationScreen(
                          driver: widget.driver,
                          pickup: widget.pickup,
                          drop: widget.drop,
                          date: widget.date,
                          distance: _estimatedDistance,
                          fare: _estimatedFare,
                          rentalPackage: widget.rentalPackage,
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
