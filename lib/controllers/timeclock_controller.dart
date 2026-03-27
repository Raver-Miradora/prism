import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/time_log.dart';
import '../data/repositories/time_log_repository.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';

// Riverpod Setup
final timeLogRepositoryProvider = Provider((ref) => TimeLogRepository());
final locationServiceProvider = Provider((ref) => LocationService());
final cameraServiceProvider = Provider((ref) => CameraService());

class TimeclockState {
  final TimeLog? activeLog;
  final double accumulatedHours;
  final int targetHours;
  final bool isLoading;

  TimeclockState({
    this.activeLog,
    this.accumulatedHours = 0.0,
    this.targetHours = 486,
    this.isLoading = false,
  });

  TimeclockState copyWith({
    TimeLog? activeLog,
    double? accumulatedHours,
    int? targetHours,
    bool? isLoading,
  }) {
    return TimeclockState(
      activeLog: activeLog ?? this.activeLog,
      accumulatedHours: accumulatedHours ?? this.accumulatedHours,
      targetHours: targetHours ?? this.targetHours,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final timeclockControllerProvider = StateNotifierProvider<TimeclockController, TimeclockState>((ref) {
  return TimeclockController(
    ref.read(timeLogRepositoryProvider),
    ref.read(locationServiceProvider),
    ref.read(cameraServiceProvider),
  );
});

class TimeclockController extends StateNotifier<TimeclockState> {
  final TimeLogRepository _repository;
  final LocationService _location;
  final CameraService _camera;

  TimeclockController(this._repository, this._location, this._camera) : super(TimeclockState()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    state = state.copyWith(isLoading: true);
    
    // Check if there is an active shift today
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final activeLog = await _repository.getActiveLogForToday(todayStr);
    
    // Load analytical accumulated progress
    final accumulated = await _repository.getAccumulatedHours();

    state = state.copyWith(
      activeLog: activeLog,
      accumulatedHours: accumulated,
      isLoading: false,
    );
  }

  Future<void> clockIn() async {
    if (state.activeLog != null) return; // Already clocked in

    state = state.copyWith(isLoading: true);
    try {
      final position = await _location.getCurrentPosition();
      final photoPath = await _camera.takeSelfie();
      
      final now = DateTime.now();
      
      final log = TimeLog(
        date: now.toIso8601String().split('T')[0],
        timeIn: now.toIso8601String(),
        latitudeIn: position.latitude,
        longitudeIn: position.longitude,
        photoPathIn: photoPath,
      );

      await _repository.insertLog(log);
      
      // Reload logic
      await _loadInitialState();
    } catch (e) {
      // Re-throw or handle analytics (skipping for simplicity).
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> clockOut() async {
    if (state.activeLog == null) return; // Not clocked in

    state = state.copyWith(isLoading: true);
    try {
      final position = await _location.getCurrentPosition();
      final photoPath = await _camera.takeSelfie();
      
      final log = state.activeLog!.copyWith(
        timeOut: DateTime.now().toIso8601String(),
        latitudeOut: position.latitude,
        longitudeOut: position.longitude,
        photoPathOut: photoPath,
      );

      await _repository.updateLog(log);
      
      // Reload analytical hours and clear active shift.
      await _loadInitialState();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}
