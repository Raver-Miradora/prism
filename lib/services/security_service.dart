import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final securityServiceProvider = Provider((ref) => SecurityService());

class SecurityService {
  static const _platform = MethodChannel('ph.gov.lagonoy.prism.security/settings');
  
  /// Checks if Android's "Automatic Date & Time" is enabled.
  /// Falls back to true on non-Android platforms for development.
  Future<bool> isAutoTimeEnabled() async {
    try {
      final bool? isEnabled = await _platform.invokeMethod<bool>('isAutoTimeEnabled');
      return isEnabled ?? false;
    } on PlatformException catch (_) {
      // If not implemented on this platform (e.g. iOS/Web), we return true to not block development
      // unless specifically requested to handle other platforms.
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Provides a stream that periodically checks the auto-time status.
  Stream<bool> watchAutoTime() async* {
    while (true) {
      yield await isAutoTimeEnabled();
      await Future.delayed(const Duration(seconds: 5));
    }
  }
}

final autoTimeProvider = StreamProvider<bool>((ref) {
  return ref.watch(securityServiceProvider).watchAutoTime();
});
