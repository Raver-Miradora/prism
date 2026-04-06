import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  /// Ensures permissions are granted and returns the current position with a safety timeout.
  Future<Position> getCurrentPosition({Duration timeout = const Duration(seconds: 15)}) async {
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
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Set to High instead of BestForNavigation to prevent offline freezing
      ).timeout(timeout); // Hard enforce dart timeout
    } on TimeoutException {
      throw LocationException('GPS signal weak or timed out. Try moving near a window or using Wi-Fi for setup.');
    } catch (e) {
      throw LocationException('Could not determine location: $e');
    }
  }

  /// Returns the distance in meters between two coordinates.
  double getDistanceBetween(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
