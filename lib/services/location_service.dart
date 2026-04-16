import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  /// Ensures permissions are granted and returns a position.
  /// Prioritizes a fresh fetch with a timeout, but falls back to the last known
  /// position if the fetch fails or times out to prevent UX blocks.
  Future<Position> getCurrentPosition({
    Duration freshTimeout = const Duration(seconds: 10),
    LocationAccuracy accuracy = LocationAccuracy.low,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      // Re-check after returning from settings
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are required. Please turn on your device GPS.');
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException('Location permissions are permanently denied.');
    }

    try {
      // 1. Primary: Fresh Fetch with aggressive accuracy and strict timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      ).timeout(freshTimeout);

    } catch (e) {
      // 2. Secondary: If fresh fetch fails (timeout or error), fall back to last known immediately
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }

      // 3. Last Resort: Fail
      if (e is TimeoutException) {
        throw LocationException('Signal weak. Please step outside or connect to Wi-Fi for a faster fix.');
      }
      throw LocationException('Unable to capture location: $e');
    }
  }

  /// Returns the distance in meters between two coordinates.
  double getDistanceBetween(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
