import 'package:flutter_test/flutter_test.dart';
import 'package:prism/core/utils/hourglass_engine.dart';
import 'package:prism/data/models/time_log.dart';
import 'package:prism/data/models/intern_settings.dart';

void main() {
  group('HourglassEngine - Rendered Time & DTR Rules', () {
    // Shared settings across tests (Standard 8am to 5pm configuration)
    final settings = InternSettings(
      expectedTimeIn: '08:00',
      expectedTimeOut: '17:00',
      programType: 'OJT',
      schoolName: 'PRISM University',
      courseProgram: 'BS IT',
      targetHours: 600,
      lunchBreakMins: 60,
    );

    test('Standard 8-Hour Shift', () {
      final log = TimeLog(
        id: 1,
        date: '2023-10-10',
        status: 'WORK',
        amArrivalTime: '2023-10-10 08:00:00',
        pmDepartureTime: '2023-10-10 17:00:00', 
      );
      
      final renderedTime = HourglassEngine.calculateDtrRenderedHours(log, settings);
      
      // Exactly 8.0 hours expected.
      expect(renderedTime, 8.0);
    });

    test('Excess Minutes Stripped (DTR Rules)', () {
      final log = TimeLog(
        id: 2,
        date: '2023-10-10',
        status: 'WORK',
        amArrivalTime: '2023-10-10 08:05:00', // 5 mins late
        pmDepartureTime: '2023-10-10 17:17:00', // 17 mins excess (overtime)
      );
      
      // Expected calculation:
      // Standard shift (8.0 hours) MINUS 5 minutes tardiness (5/60 = ~0.0833).
      // The 17 minutes of overtime after 17:00 should be explicitly ignored.
      // 8.0 - 0.08333... = 7.91666... rounding to fixed 2 decimals -> 7.92
      final renderedTime = HourglassEngine.calculateDtrRenderedHours(log, settings);
      
      expect(renderedTime, 7.92);
    });

    test('Undertime Calculation', () {
      final log = TimeLog(
        id: 3,
        date: '2023-10-10',
        status: 'WORK',
        amArrivalTime: '2023-10-10 08:00:00', 
        pmDepartureTime: '2023-10-10 15:30:00', // 1 hr 30 mins early
      );
      
      // Expected calculation:
      // Standard shift (8.0 hours) MINUS early departure of 90 minutes.
      // 8.0 - 1.5 = 6.5 hours
      final renderedTime = HourglassEngine.calculateDtrRenderedHours(log, settings);
      
      expect(renderedTime, 6.5);
    });
  });
}
