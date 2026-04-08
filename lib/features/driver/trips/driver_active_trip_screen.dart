import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/models.dart';

class DriverActiveTripScreen extends ConsumerStatefulWidget {
  final Booking booking;

  const DriverActiveTripScreen({super.key, required this.booking});

  @override
  ConsumerState<DriverActiveTripScreen> createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends ConsumerState<DriverActiveTripScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isTripStarted = false;
  bool _isTripEnded = false;
  double _distanceCovered = 0.0;
  double _finalFare = 0.0;
  Timer? _tripTimer;

  @override
  void dispose() {
    _otpController.dispose();
    _tripTimer?.cancel();
    super.dispose();
  }

  void _startRide() {
    if (_otpController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP')),
      );
      return;
    }
    setState(() {
      _isTripStarted = true;
    });
    
    // Simulate active ride tracking
    _tripTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _distanceCovered += 0.5; // add 0.5 km every 2 secs for simulation
      });
    });
  }

  void _endRide() {
    _tripTimer?.cancel();
    setState(() {
      _isTripEnded = true;
      // Calculate final fare: booking charge + distance * price_per_km
      _finalFare = widget.booking.totalFare + (_distanceCovered * 15); // mock 15 per km
    });
  }

  void _sendPaymentRequest() {
    // Update booking in global state for earnings/history
    ref.read(bookingProvider.notifier).updateStatus(widget.booking.id, 'Completed');
    
    // In a real app we'd update fare too. For demo, we'll just show the success toast.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment request for ₹${_finalFare.toStringAsFixed(0)} sent to customer!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Trip'),
      ),
      body: Column(
        children: [
          // Mock Map Area
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Map View', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStateContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateContent() {
    if (_isTripEnded) {
      return _buildTripEndedView();
    } else if (_isTripStarted) {
      return _buildActiveRideView();
    } else {
      return _buildOtpEntryView();
    }
  }

  Widget _buildOtpEntryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Start Ride', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Ask customer for the 4-digit OTP to start the ride.', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: 'Enter OTP',
            prefixIcon: const Icon(Icons.security),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _startRide,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Verify & Start Ride', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveRideView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.directions_car, size: 64, color: AppTheme.primaryColor),
        const SizedBox(height: 16),
        const Text('Ride in Progress', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Distance', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('${_distanceCovered.toStringAsFixed(1)} KM', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              children: [
                const Text('Est. Fare', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('₹${(widget.booking.totalFare + (_distanceCovered*15)).toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _endRide,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('End Trip', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTripEndedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        const Text('Trip Completed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Total Distance', '${_distanceCovered.toStringAsFixed(1)} KM'),
              const Divider(height: 24),
              _buildSummaryRow('Final Fare', '₹${_finalFare.toStringAsFixed(0)}', isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _sendPaymentRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Send Payment Request', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
        Text(value, style: TextStyle(fontSize: isBold ? 20 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: isBold ? AppTheme.primaryColor : Colors.black87)),
      ],
    );
  }
}
