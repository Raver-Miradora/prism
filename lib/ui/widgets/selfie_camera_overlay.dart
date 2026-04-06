import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/theme/civic_horizon_theme.dart';

class SelfieCameraOverlay extends StatefulWidget {
  const SelfieCameraOverlay({super.key});

  @override
  State<SelfieCameraOverlay> createState() => _SelfieCameraOverlayState();
}

class _SelfieCameraOverlayState extends State<SelfieCameraOverlay> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isCapturing = false;
  
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableClassification: false,
      enableLandmarks: false,
      enableTracking: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  bool _isProcessing = false;
  bool _faceDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        throw 'No camera found on this device.';
      }

      // Filter for front camera exclusively, with fallback to first available
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, // Use nv21 or yuv420 for ML Kit on Android/iOS
      );

      await _controller?.initialize();
      
      if (!mounted) return;
      
      await _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      _controller?.startImageStream((CameraImage image) {
        if (_isProcessing) return;
        _isProcessing = true;
        _processImage(image);
      });
      
      setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, 'ERROR: ${e.toString()}');
      }
    }
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      
      final camera = _controller!.description;
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation270deg;
      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final inputImageMetadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
      
      final faces = await _faceDetector.processImage(inputImage);
      
      if (mounted) {
        final hasFace = faces.length == 1;
        if (_faceDetected != hasFace) {
          setState(() => _faceDetected = hasFace);
        }
      }
    } catch (e) {
      // Ignored
    } finally {
      if (mounted) {
        _isProcessing = false;
      }
    }
  }

  @override
  void dispose() {
    if (_controller?.value.isStreamingImages == true) {
      _controller?.stopImageStream();
    }
    _faceDetector.close();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing || !_faceDetected) return;

    setState(() => _isCapturing = true);
    HapticFeedback.mediumImpact();

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final XFile photo = await controller.takePicture();
      if (mounted) {
        Navigator.pop(context, photo.path);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          Center(
            child: _controller != null 
              ? CameraPreview(_controller!) 
              : const CircularProgressIndicator(),
          ),

          // 2. Face Guide Overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 100),
                    height: 380,
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: const BorderRadius.all(Radius.elliptical(140, 190)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. UI Elements
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'FACIAL VERIFICATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer for balance
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _faceDetected ? 'Face detected' : 'Align your face within the guide',
                  style: TextStyle(
                    color: _faceDetected ? Colors.greenAccent : Colors.white70,
                    fontSize: 14,
                    fontWeight: _faceDetected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Capture Button
                GestureDetector(
                  onTap: _faceDetected ? _capture : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 80,
                    width: 80,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _faceDetected ? Colors.white : Colors.white30, width: 4),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _faceDetected ? Colors.white : Colors.white30,
                        shape: BoxShape.circle,
                      ),
                      child: _isCapturing
                        ? const Center(child: CircularProgressIndicator(color: CivicHorizonTheme.primary))
                        : (!_faceDetected ? const Center(child: Icon(Icons.face, color: Colors.black54, size: 36)) : null),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
