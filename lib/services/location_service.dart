import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  /// Ensures permissions are granted and returns the position using cached records first.
  /// If the cache is stale, fetches a fresh low-accuracy position with a strict timeout.
  Future<Position> getCurrentPosition({Duration freshTimeout = const Duration(seconds: 5)}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      // Re-check after returning from settings
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are required to verify your office presence. Please turn on your device GPS.');
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
      throw LocationException(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      // 1. Check Cached Location First
      final Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      
      if (lastKnownPosition != null) {
        final age = DateTime.now().difference(lastKnownPosition.timestamp);
        // If the position is less than 5 minutes old, return it instantly
        if (age < const Duration(minutes: 5)) {
          return lastKnownPosition;
        }
      }

      // 2. Low-Accuracy Fresh Fetch (with 3. Strict Timeout Rule)
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // Lower accuracy prevents trying to lock onto distant GPS satellites
      ).timeout(freshTimeout);

    } on TimeoutException {
      throw LocationException('Unable to verify location. Please step outside or connect to the internet momentarily.');
    } catch (e) {
      throw LocationException('Could not determine location: $e');
    }
  }

  /// Returns the distance in meters between two coordinates.
  double getDistanceBetween(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
