import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapView extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final Function(LatLng)? onLocationSelected;

  /// For trip tracking: show route from pickupLocation to dropoffLocation
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;
  final bool showRoute;

  const MapView({
    super.key,
    this.initialLat,
    this.initialLng,
    this.onLocationSelected,
    this.pickupLocation,
    this.dropoffLocation,
    this.showRoute = false,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;
  LatLng _currentPosition = const LatLng(17.3850, 78.4867);
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _setupMarkersAndRoute();
  }

  void _setupMarkersAndRoute() {
    if (widget.pickupLocation != null && widget.dropoffLocation != null && widget.showRoute) {
      // Add pickup marker
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: widget.pickupLocation!,
          infoWindow: const InfoWindow(title: 'Pickup Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Add dropoff marker
      _markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: widget.dropoffLocation!,
          infoWindow: const InfoWindow(title: 'Dropoff Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Add polyline (route)
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [widget.pickupLocation!, widget.dropoffLocation!],
          color: Colors.blue,
          width: 5,
          geodesic: true,
        ),
      );

      // Zoom to fit both locations
      _fitRouteBounds();
    } else {
      // Default marker at current position
      _markers.add(
        Marker(
          markerId: const MarkerId('current_pos'),
          position: _currentPosition,
        ),
      );
    }
  }

  void _fitRouteBounds() {
    if (widget.pickupLocation == null || widget.dropoffLocation == null || _controller == null) return;

    final southwest = LatLng(
      math.min(widget.pickupLocation!.latitude, widget.dropoffLocation!.latitude) - 0.01,
      math.min(widget.pickupLocation!.longitude, widget.dropoffLocation!.longitude) - 0.01,
    );
    final northeast = LatLng(
      math.max(widget.pickupLocation!.latitude, widget.dropoffLocation!.latitude) + 0.01,
      math.max(widget.pickupLocation!.longitude, widget.dropoffLocation!.longitude) + 0.01,
    );

    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<void> _determinePosition() async {
    // Use provided initial location or current location
    if (widget.initialLat != null && widget.initialLng != null) {
      setState(() {
        _currentPosition = LatLng(widget.initialLat!, widget.initialLng!);
        _isLoading = false;
      });
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    if (_controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition,
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _controller = controller;
        if (widget.showRoute && widget.pickupLocation != null && widget.dropoffLocation != null) {
          Future.delayed(const Duration(milliseconds: 500), _fitRouteBounds);
        }
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onTap: (latLng) {
        setState(() => _currentPosition = latLng);
        widget.onLocationSelected?.call(latLng);
      },
      markers: _markers,
      polylines: _polylines,
    );
  }
}
