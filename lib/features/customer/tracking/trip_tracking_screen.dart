import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/firestore_service.dart';
import '../../../core/location_service.dart';
import '../summary/trip_summary_screen.dart';
import '../../../widgets/map_view.dart';

const _kMapsApiKey = 'AIzaSyDdKt_rjoSjVz4k9TXa9nakXo8qTgpy_3I';

class TripTrackingScreen extends ConsumerStatefulWidget {
  final TripRequest trip;
  final DriverModel driver;

  const TripTrackingScreen({
    super.key,
    required this.trip,
    required this.driver,
  });

  @override
  ConsumerState<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends ConsumerState<TripTrackingScreen> {
  BookingStatus _currentStatus = BookingStatus.driverAccepted;
  int _secondsLeft = 180;
  Timer? _timer;
  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;

  @override
  void initState() {
    super.initState();
    _startSimulation();
    _geocodeLocations();
  }

  Future<void> _geocodeLocations() async {
    _pickupLatLng = await _geocode(widget.trip.pickupLocation);
    _dropLatLng = await _geocode(widget.trip.dropLocation);
    if (mounted) setState(() {});
  }

  Future<LatLng?> _geocode(String address) async {
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {'address': address, 'key': _kMapsApiKey},
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final loc = results[0]['geometry']['location'] as Map<String, dynamic>;
          return LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
        }
      }
    } catch (_) {}
    return null;
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

  void _completeTrip() async {
    final completedTrip = widget.trip.copyWith(
      status: BookingStatus.tripCompleted,
      actualDistance: widget.trip.estimatedDistance + 2.0, // Simulation: traveled slightly more
      finalFare: widget.trip.estimatedFare + 24.0, // Extra for 2km
      paymentStatus: PaymentStatus.pending, // Final payment pending
    );

    // Save to Firestore
    await ref.read(firestoreServiceProvider).updateTrip(completedTrip);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TripSummaryScreen(trip: completedTrip, driver: widget.driver)),
      );
    }
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
    return MapView(
      initialLat: _pickupLatLng?.latitude ?? 17.3850,
      initialLng: _pickupLatLng?.longitude ?? 78.4867,
      pickupLocation: _pickupLatLng,
      dropoffLocation: _dropLatLng,
      showRoute: _pickupLatLng != null && _dropLatLng != null,
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
            _buildOtpDisplay(),
            const Divider(height: 24),
            _buildDistanceAndFare(),
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
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
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
            '1234',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4, color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceAndFare() {
    final trip = widget.trip;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trip Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  LocationService.formatDistance(trip.estimatedDistance),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Estimated Fare',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${trip.estimatedFare.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ETA',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  LocationService.formatDuration(_secondsLeft),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
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
            onPressed: _callDriver,
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
              onPressed: _cancelRequest,
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
              onPressed: _shareStatus,
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

  Future<void> _callDriver() async {
    final phone = widget.driver.mobileNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot call ${widget.driver.mobileNumber}')),
      );
    }
  }

  Future<void> _cancelRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text('Are you sure you want to cancel this ride request?'),
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
    _timer?.cancel();
    final cancelled = widget.trip.copyWith(status: BookingStatus.cancelled);
    await ref.read(firestoreServiceProvider).updateTrip(cancelled);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ride cancelled successfully')),
    );
  }

  void _shareStatus() {
    final trip = widget.trip;
    final driver = widget.driver;
    final eta = '${(_secondsLeft ~/ 60)}m ${(_secondsLeft % 60)}s';
    final text = '''🚖 Nova Cabs — Trip Status
From: ${trip.pickupLocation}
To: ${trip.dropLocation}
Driver: ${driver.fullName}
Vehicle: ${driver.vehicleModel} (${driver.vehicleNumber})
ETA: $eta
Fare: ₹${trip.estimatedFare.toStringAsFixed(0)}''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip status copied to clipboard')),
    );
  }
}
