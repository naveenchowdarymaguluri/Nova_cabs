import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/app_theme.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final String title;
  final LatLng? initialPosition;

  const MapLocationPickerScreen({
    super.key,
    required this.title,
    this.initialPosition,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _pickedPosition = const LatLng(12.9716, 77.5946); // default: Bangalore
  String _address = 'Move the map to select location';
  bool _isLoading = false;
  bool _isFetchingAddress = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _pickedPosition = widget.initialPosition!;
    }
    _fetchAddress(_pickedPosition);
  }

  Future<void> _fetchAddress(LatLng position) async {
    setState(() => _isFetchingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.name != null && p.name!.isNotEmpty && p.name != p.thoroughfare) p.name!,
          if (p.thoroughfare != null && p.thoroughfare!.isNotEmpty) p.thoroughfare!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea!,
        ].where((s) => s.isNotEmpty).toSet().toList();
        setState(() => _address = parts.take(4).join(', '));
      }
    } catch (_) {
      setState(() => _address = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}');
    } finally {
      setState(() => _isFetchingAddress = false);
    }
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied. Enable it in settings.')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latlng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
      setState(() => _pickedPosition = latlng);
      await _fetchAddress(latlng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedPosition,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              _pickedPosition = position.target;
            },
            onCameraIdle: () {
              _fetchAddress(_pickedPosition);
            },
          ),

          // Center pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 48),
                // Pin stem shadow
                Container(
                  width: 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          // App bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                          ],
                        ),
                        child: Text(
                          widget.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // My location button
          Positioned(
            right: 16,
            bottom: 200,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.my_location, color: AppTheme.primaryColor),
                      onPressed: _goToCurrentLocation,
                    ),
            ),
          ),

          // Bottom address card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selected Location',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isFetchingAddress
                            ? const SizedBox(
                                height: 16,
                                child: LinearProgressIndicator(),
                              )
                            : Text(
                                _address,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Confirm Location',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isFetchingAddress ? null : () => Navigator.pop(context, _address),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
