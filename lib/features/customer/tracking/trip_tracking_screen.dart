import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../summary/trip_summary_screen.dart';

class TripTrackingScreen extends StatefulWidget {
  final TripRequest trip;
  final DriverModel driver;

  const TripTrackingScreen({
    super.key,
    required this.trip,
    required this.driver,
  });

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  BookingStatus _currentStatus = BookingStatus.driverAccepted;
  int _secondsLeft = 180; // 3 minutes until arrival
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        }
        
        // Progress simulation
        if (_secondsLeft == 160) _currentStatus = BookingStatus.driverArriving;
        if (_secondsLeft == 140) _currentStatus = BookingStatus.tripStarted;
        
        if (_secondsLeft == 0) {
          _timer?.cancel();
          _completeTrip();
        }
      });
    });
  }

  void _completeTrip() {
    final completedTrip = TripRequest(
      id: widget.trip.id,
      bookingId: widget.trip.bookingId,
      customerId: widget.trip.customerId,
      customerName: widget.trip.customerName,
      customerPhone: widget.trip.customerPhone,
      pickupLocation: widget.trip.pickupLocation,
      dropLocation: widget.trip.dropLocation,
      estimatedDistance: widget.trip.estimatedDistance,
      estimatedFare: widget.trip.estimatedFare,
      cabType: widget.trip.cabType,
      tripDate: widget.trip.tripDate,
      tripTime: widget.trip.tripTime,
      status: BookingStatus.tripCompleted,
      driverId: widget.trip.driverId,
      advancePaid: widget.trip.advancePaid,
      actualDistance: widget.trip.estimatedDistance + 2.0, // Simulation: traveled slightly more
      finalFare: widget.trip.estimatedFare + 24.0, // Extra for 2km
      paymentStatus: PaymentStatus.pending, // Final payment pending
      createdAt: widget.trip.createdAt,
      rentalPackage: widget.trip.rentalPackage,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TripSummaryScreen(trip: completedTrip, driver: widget.driver)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMapPlaceholder(),
          _buildTopOverlay(),
          _buildBottomStatusCard(),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: Colors.blue.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text(
              'Live Map - Driver is ${_currentStatus.name}',
              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '${(_secondsLeft ~/ 60)}m ${(_secondsLeft % 60)}s',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStatusCard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusHeader(),
            const Divider(height: 24),
            _buildOtpDisplay(), // Added OTP display
            const Divider(height: 24),
            _buildDriverInfo(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    String message = 'Finding your ride...';
    if (_currentStatus == BookingStatus.driverAccepted) message = 'Driver Accepted your ride';
    if (_currentStatus == BookingStatus.driverArriving) message = 'Driver is arriving at pickup';
    if (_currentStatus == BookingStatus.tripStarted) message = 'Trip in progress...';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.local_taxi, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('NOVA CABS Safe Trip', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Ride OTP', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Text(
            '1234', // Mock OTP
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4, color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
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
              Text(widget.driver.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${widget.driver.vehicleModel} • ${widget.driver.vehicleNumber}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
          child: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 14),
              SizedBox(width: 4),
              Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call),
            label: const Text('Call Driver'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (_currentStatus != BookingStatus.tripStarted)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        else
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text('Share Status', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
    );
  }
}
