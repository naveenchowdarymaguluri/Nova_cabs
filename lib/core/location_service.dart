import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(LatLng start, LatLng end) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(end.latitude - start.latitude);
    final dLng = _degreesToRadians(end.longitude - start.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(start.latitude)) *
            math.cos(_degreesToRadians(end.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Calculate fare based on distance and rate per km
  /// Formula: baseFare + (distance * perKmRate)
  static double calculateFare({
    required double distance,
    required double baseFare,
    required double perKmRate,
    double nightChargeMultiplier = 1.0,
  }) {
    final distanceFare = distance * perKmRate;
    return (baseFare + distanceFare) * nightChargeMultiplier;
  }

  /// Format distance for display
  static String formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    }
    return '${km.toStringAsFixed(2)} km';
  }

  /// Format duration from seconds
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${remainingMinutes}m';
  }
}
