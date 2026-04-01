import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/time_log.dart';
import '../data/repositories/time_log_repository.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';
import '../core/database/database_helper.dart';
import 'settings_controller.dart';

// Riverpod Setup
final timeLogRepositoryProvider = Provider((ref) => TimeLogRepository());
final locationServiceProvider = Provider((ref) => LocationService());
final cameraServiceProvider = Provider((ref) => CameraService());

enum PunchPhase { amIn, lunchOut, lunchIn, pmOut, done }

class TimeclockState {
  final TimeLog? activeLog;
  final double accumulatedHours;
  final int targetHours;
  final String? errorMessage;
  final bool isLoading;
  final bool isFieldworkMode;

  TimeclockState({
    this.activeLog,
    this.accumulatedHours = 0.0,
    this.targetHours = 486,
    this.errorMessage,
    this.isLoading = false,
    this.isFieldworkMode = false,
  });

  TimeclockState copyWith({
    TimeLog? activeLog,
    double? accumulatedHours,
    int? targetHours,
    String? errorMessage,
    bool? isLoading,
    bool? isFieldworkMode,
  }) {
    return TimeclockState(
      activeLog: activeLog ?? this.activeLog,
      accumulatedHours: accumulatedHours ?? this.accumulatedHours,
      targetHours: targetHours ?? this.targetHours,
      errorMessage: errorMessage, // We reset error on copy if not provided
      isLoading: isLoading ?? this.isLoading,
      isFieldworkMode: isFieldworkMode ?? this.isFieldworkMode,
    );
  }

  PunchPhase get punchPhase {
    if (activeLog == null || activeLog!.timeIn == null) return PunchPhase.amIn;
    if (activeLog!.timeLunchOut == null) return PunchPhase.lunchOut;
    if (activeLog!.timeLunchIn == null) return PunchPhase.lunchIn;
    if (activeLog!.timeOut == null) return PunchPhase.pmOut;
    return PunchPhase.done;
  }
}

final timeclockControllerProvider = StateNotifierProvider<TimeclockController, TimeclockState>((ref) {
  return TimeclockController(
    ref.read(timeLogRepositoryProvider),
    ref.read(locationServiceProvider),
    ref.read(cameraServiceProvider),
    ref,
  );
});

class TimeclockController extends StateNotifier<TimeclockState> {
  final TimeLogRepository _repository;
  final LocationService _location;
  final CameraService _camera;
  final Ref _ref;

  TimeclockController(this._repository, this._location, this._camera, this._ref) : super(TimeclockState()) {
    _loadInitialState();
  }

  void toggleFieldworkMode(bool value) {
    state = state.copyWith(isFieldworkMode: value);
  }

  Future<void> _loadInitialState() async {
    state = state.copyWith(isLoading: true);
    
    // Fetch dynamic target hours so the Hourglass updates correctly
    final db = await DatabaseHelper.instance.database;
    final map = await db.query('intern_settings', limit: 1);
    int dynamicTargetHours = 486;
    if (map.isNotEmpty) {
      dynamicTargetHours = map.first['targetHours'] as int? ?? 486;
    }

    // Check if there is an active shift today
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final activeLog = await _repository.getActiveLogForToday(todayStr);
    
    // Load analytical accumulated progress
    final accumulated = await _repository.getAccumulatedHours();

    state = state.copyWith(
      activeLog: activeLog,
      accumulatedHours: accumulated,
      targetHours: dynamicTargetHours,
      isLoading: false,
    );
  }

  Future<void> punchTimeclock() async {
    final phase = state.punchPhase;
    if (phase == PunchPhase.done) return; // Shift completed

    state = state.copyWith(isLoading: true);
    try {
      final settingsState = _ref.read(settingsProvider);
      final settings = settingsState.settings;
      final position = await _location.getCurrentPosition();

      // Location Verification Check (Applies for all punches if not fieldwork)
      if (!state.isFieldworkMode && settings != null && settings.officeLat != null && settings.officeLng != null) {
        final distance = _location.getDistanceBetween(
          position.latitude, 
          position.longitude, 
          settings.officeLat!, 
          settings.officeLng!,
        );
        
        if (distance > 200) {
          throw 'Out of Bounds: You are ${distance.round()}m away from the office. Location verification requires a 200m radius.';
        }
      }

      final photoPath = await _camera.takeSelfie();
      final timeNow = DateTime.now().toIso8601String();
      
      TimeLog log;

      if (phase == PunchPhase.amIn) {
        log = TimeLog(
          date: timeNow.split('T')[0],
          timeIn: timeNow,
          latitudeIn: position.latitude,
          longitudeIn: position.longitude,
          photoPathIn: photoPath,
          isFieldwork: state.isFieldworkMode,
          status: 'WORK',
        );
        await _repository.insertLog(log);
      } else {
        log = state.activeLog!;
        if (phase == PunchPhase.lunchOut) {
          log = log.copyWith(timeLunchOut: timeNow);
        } else if (phase == PunchPhase.lunchIn) {
          log = log.copyWith(timeLunchIn: timeNow);
        } else if (phase == PunchPhase.pmOut) {
          log = log.copyWith(
            timeOut: timeNow,
            latitudeOut: position.latitude,
            longitudeOut: position.longitude,
            photoPathOut: photoPath,
          );
        }
        await _repository.updateLog(log);
      }
      
      // If PM Out complete, reset fieldwork mode
      if (phase == PunchPhase.pmOut && state.isFieldworkMode) {
        state = state.copyWith(isFieldworkMode: false);
      }
      
      // Reload logic and hours
      await _loadInitialState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().contains('Out of Bounds') ? e.toString() : 'Punch failed: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Manually log an attendance status like ABSENT or EXCUSED for a specific day.
  Future<void> logAttendanceStatus(DateTime date, String status, String remarks) async {
    state = state.copyWith(isLoading: true);
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      
      // Check if a log already exists for this day
      final existing = await _repository.getActiveLogForToday(dateStr);
      if (existing != null) {
        throw 'A log entry already exists for $dateStr. Please delete it first if you wish to overwrite.';
      }

      final log = TimeLog(
        date: dateStr,
        status: status,
        remarks: remarks,
        // Provide dummy data for mandatory-ish logic in other parts of the app
        timeIn: null, 
        latitudeIn: 0.0,
        longitudeIn: 0.0,
        photoPathIn: null,
      );

      await _repository.insertLog(log);
      await _loadInitialState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Manual logging failed: ${e.toString()}',
      );
    }
  }

}
