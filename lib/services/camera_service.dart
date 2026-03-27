import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraException implements Exception {
  final String message;
  CameraException(this.message);
}

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Prompts the user to take a selfie using the device's native camera.
  /// Saves the image locally to the app's document directory to persist securely.
  /// Returns the absolute path to the saved `.jpg`.
  Future<String> takeSelfie() async {
    // Attempt to open the front-facing native camera
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 50, // Keep sizes small for offline SQLite bloat control
    );

    if (photo == null) {
      throw CameraException('User cancelled the camera capture.');
    }

    // Save strictly to app documents directory to prevent deletion from standard gallery
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().toIso8601String().replaceAll(':', '-')}_selfie.jpg';
    final savedImage = File(join(appDir.path, fileName));

    await File(photo.path).copy(savedImage.path);
    
    // Clean up temporary cache provided by image_picker
    try {
      await File(photo.path).delete();
    } catch (_) {}

    return savedImage.path;
  }
}
