import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/time_log.dart';
import '../data/repositories/time_log_repository.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../core/database/database_helper.dart';
import 'settings_controller.dart';
import 'reports_controller.dart';

// Riverpod Setup
final timeLogRepositoryProvider = Provider((ref) => TimeLogRepository());
final locationServiceProvider = Provider((ref) => LocationService());
final cameraServiceProvider = Provider((ref) => CameraService());

enum PunchPhase { amIn, pmOut, done }

class TimeclockState {
  final TimeLog? activeLog;
  final double accumulatedHours;
  final int targetHours;
  final String? errorMessage;
  final bool isLoading;
  final bool isFieldworkMode;
  final String? fieldworkLocation;
  final String? fieldworkPurpose;

  TimeclockState({
    this.activeLog,
    this.accumulatedHours = 0.0,
    this.targetHours = 486,
    this.errorMessage,
    this.isLoading = false,
    this.isFieldworkMode = false,
    this.fieldworkLocation,
    this.fieldworkPurpose,
  });

  TimeclockState copyWith({
    TimeLog? activeLog,
    double? accumulatedHours,
    int? targetHours,
    String? errorMessage,
    bool? isLoading,
    bool? isFieldworkMode,
    String? fieldworkLocation,
    String? fieldworkPurpose,
  }) {
    return TimeclockState(
      activeLog: activeLog ?? this.activeLog,
      accumulatedHours: accumulatedHours ?? this.accumulatedHours,
      targetHours: targetHours ?? this.targetHours,
      errorMessage: errorMessage, // We reset error on copy if not provided
      isLoading: isLoading ?? this.isLoading,
      isFieldworkMode: isFieldworkMode ?? this.isFieldworkMode,
      fieldworkLocation: fieldworkLocation ?? this.fieldworkLocation,
      fieldworkPurpose: fieldworkPurpose ?? this.fieldworkPurpose,
    );
  }

  PunchPhase get punchPhase {
    final log = activeLog;
    if (log == null || log.amArrivalTime == null) return PunchPhase.amIn;
    if (log.pmDepartureTime == null) return PunchPhase.pmOut;
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

  void toggleFieldworkMode(bool value, {String? location, String? purpose}) {
    state = state.copyWith(
      isFieldworkMode: value,
      fieldworkLocation: location,
      fieldworkPurpose: purpose,
    );
  }

  Future<void> _loadInitialState() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Fetch dynamic target hours so the Hourglass updates correctly
      final db = await DatabaseHelper.instance.database;
      final map = await db.query('intern_settings', limit: 1);
      int dynamicTargetHours = 486;
      if (map.isNotEmpty) {
        dynamicTargetHours = map.first['target_hours'] as int? ?? 486;
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
    } catch (e, stack) {
      debugPrint('PRISM_CRITICAL_FAILURE in _loadInitialState: ${e.toString()}');
      debugPrint('STACK_TRACE: $stack');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load initial state: ${e.toString()}',
      );
    }
  }

  Future<void> punchTimeclock() async {
    final phase = state.punchPhase;
    if (phase == PunchPhase.done) return; // Shift completed

    state = state.copyWith(isLoading: true);
    try {
      debugPrint('PRISM_LOG: Initializing punch sequence. Phase: $phase, Fieldwork: ${state.isFieldworkMode}');
      final settingsState = _ref.read(settingsProvider);
      final settings = settingsState.settings;
      
      // ── STEP 1 (ALWAYS): Biometric Verification ───────────────────────────
      debugPrint('PRISM_LOG: Requesting device authentication...');
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      
      if (canAuthenticate) {
        try {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Please authenticate to verify your identity for time-in',
            options: const AuthenticationOptions(biometricOnly: false),
          );
          if (!didAuthenticate) {
            throw 'Biometric verification failed or was cancelled.';
          }
        } on PlatformException catch (e) {
          // Handle devices with no lock screen security configured
          if (e.code == 'PasscodeNotSet' || e.code == 'NotEnrolled') {
            throw 'Security Requirement: Please set up a Screen Lock (PIN, Pattern, or Fingerprint) in your phone\'s Settings before you can use the timeclock.';
          }
          // Re-throw any other platform-level auth errors with context
          throw 'Authentication error (${e.code}): ${e.message ?? "Could not complete verification."}';
        }
      } else {
        throw 'Your device does not support identity verification, which is required to safely log time.';
      }

      final timeNow = DateTime.now();
      final timeStr = timeNow.toIso8601String();
      final hour = timeNow.hour;

      // Validate time window first so we fail fast before expensive ops
      _validateTimeWindow(phase, hour);

      String? photoPath;
      double? posLat;
      double? posLng;

      if (!state.isFieldworkMode) {
        // ── BRANCH A: STANDARD OFFICE ────────────────────────────────────────
        // Step 2A: GPS fetch + Haversine geofence check. NO camera.
        debugPrint('PRISM_LOG: [Office] Fetching GPS position...');
        final position = await _location.getCurrentPosition();
        posLat = position.latitude;
        posLng = position.longitude;
        debugPrint('PRISM_LOG: [Office] GPS acquired: $posLat, $posLng');

        final lat = settings?.officeLat;
        final lng = settings?.officeLng;

        if (settings != null && lat != null && lng != null) {
          final distance = _location.getDistanceBetween(posLat, posLng, lat, lng);
          debugPrint('PRISM_LOG: [Office] Distance from base: ${distance.round()}m');
          if (distance > 50) {
            throw 'Out of Bounds: You are ${distance.round()} meters away from the deployment zone. You must be within 50 meters to clock in.';
          }
        }
        // photoPath stays null — no camera for standard office clock-ins.
        debugPrint('PRISM_LOG: [Office] Geofence passed. Saving log without photo.');

      } else {
        // ── BRANCH B: FIELDWORK ───────────────────────────────────────────────
        // Step 2B: No geofence check. Capture site photo instead.
        // Still fetch location for the record but skip the 50m radius check.
        debugPrint('PRISM_LOG: [Fieldwork] Fetching GPS position for record...');
        try {
          final position = await _location.getCurrentPosition();
          posLat = position.latitude;
          posLng = position.longitude;
        } catch (_) {
          // Location is best-effort in fieldwork — do not block the punch.
          debugPrint('PRISM_LOG: [Fieldwork] GPS unavailable, proceeding without coordinates.');
        }

        debugPrint('PRISM_LOG: [Fieldwork] Launching site photo camera...');
        photoPath = await _camera.takeSelfie();
        debugPrint('PRISM_LOG: [Fieldwork] Site photo captured. Path: $photoPath');
      }

      // ── STEP 3 (ALWAYS): Persist to SQLite ──────────────────────────────────
      TimeLog log;

      if (phase == PunchPhase.amIn) {
        debugPrint('PRISM_LOG: Constructing new AM In log entry...');
        log = TimeLog(
          date: timeStr.split('T')[0],
          amArrivalTime: timeStr,
          latAmArrival: posLat ?? 0.0,
          lngAmArrival: posLng ?? 0.0,
          amArrivalPhotoPath: photoPath, // null for office, path for fieldwork
          isFieldwork: state.isFieldworkMode,
          fieldworkLocation: state.fieldworkLocation,
          fieldworkPurpose: state.fieldworkPurpose,
          status: 'WORK',
        );
        await _repository.insertLog(log);
        debugPrint('PRISM_LOG: AM In entry committed to SQLite.');
      } else {
        final existingLog = state.activeLog;
        if (existingLog == null) {
          throw 'System Error: Active log lost during punch. Please restart the app.';
        }
        debugPrint('PRISM_LOG: Syncing punch with existing session ID: ${existingLog.id}');
        log = existingLog.copyWith(
          pmDepartureTime: timeStr,
          latPmDeparture: posLat ?? 0.0,
          lngPmDeparture: posLng ?? 0.0,
          pmDeparturePhotoPath: photoPath, // null for office, path for fieldwork
        );
        await _repository.updateLog(log);
        debugPrint('PRISM_LOG: PM Out transition committed.');
      }
      
      // Reset fieldwork mode after PM Out
      if (phase == PunchPhase.pmOut && state.isFieldworkMode) {
        state = state.copyWith(
          isFieldworkMode: false,
          fieldworkLocation: null,
          fieldworkPurpose: null,
        );
      }
      
      debugPrint('PRISM_LOG: Punch successful. Refreshing UI state...');
      await _loadInitialState();
      // Sync the Reports Attendance Registry so it reflects the new punch immediately
      _ref.read(reportsControllerProvider.notifier).loadData(
        _ref.read(reportsControllerProvider).selectedYear,
        _ref.read(reportsControllerProvider).selectedMonth,
      );
    } catch (e, stack) {
      debugPrint('PRISM_CRITICAL_FAILURE: ${e.toString()}');
      debugPrint('STACK_TRACE: $stack');
      if (e is CameraException && e.message.contains('cancelled')) {
        state = state.copyWith(isLoading: false, errorMessage: null);
        return;
      }
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
        amArrivalTime: null, 
        latAmArrival: 0.0,
        lngAmArrival: 0.0,
        amArrivalPhotoPath: null,
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

  void _validateTimeWindow(PunchPhase phase, int hour) {
    if (phase == PunchPhase.amIn && (hour < 5 || hour >= 16)) {
      throw 'Invalid Window: AM IN records are only allowed between 05:00 and 15:59.';
    }
    if (phase == PunchPhase.pmOut && (hour < 11 || hour >= 23)) {
      throw 'Invalid Window: PM OUT records are only allowed between 11:00 and 22:59.';
    }
  }

  /// Special handler for recovery when a user missed a previous step.
  Future<void> logManualPunch() async {
    final phase = state.punchPhase;
    if (phase == PunchPhase.done || phase == PunchPhase.amIn) return;

    state = state.copyWith(isLoading: true);
    try {
      final existingLog = state.activeLog!;
      final timeStr = DateTime.now().toIso8601String();
      
      TimeLog log = existingLog;
      if (phase == PunchPhase.pmOut) {
        log = log.copyWith(pmDepartureTime: timeStr, isManualPmDeparture: true);
      }
      
      await _repository.updateLog(log);
      await _loadInitialState();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

}
