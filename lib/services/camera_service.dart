import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../main.dart';
import '../ui/widgets/selfie_camera_overlay.dart';
import 'package:flutter/material.dart';

class CameraException implements Exception {
  final String message;
  CameraException(this.message);

  @override
  String toString() => message;
}

class CameraService {
  /// Prompts the user to take a selfie using the custom SelfieCameraOverlay.
  /// Saves the image locally to the app's document directory to persist securely.
  /// Returns the absolute path to the saved `.jpg`.
  Future<String> takeSelfie() async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw CameraException('System Error: Navigator is not available.');
    }

    // Push the custom overlay and await the result
    final dynamic result = await navigator.push(
      MaterialPageRoute(builder: (ctx) => const SelfieCameraOverlay()),
    );

    if (result == null) {
      throw CameraException('User cancelled the camera capture.');
    }

    if (result is String && result.startsWith('ERROR:')) {
      throw CameraException(result.replaceFirst('ERROR:', '').trim());
    }

    final String photoPath = result as String;

    // Save strictly to app documents directory to prevent deletion from standard gallery
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().toIso8601String().replaceAll(':', '-')}_selfie.jpg';
    final savedImage = File(join(appDir.path, fileName));

    await File(photoPath).copy(savedImage.path);
    
    // Clean up temporary cache provided by camera package
    try {
      await File(photoPath).delete();
    } catch (_) {}

    return savedImage.path;
  }
}
