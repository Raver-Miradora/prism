import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Encapsulates the visual state of the application, including the active 
/// theme mode (light/dark) and the primary seed color for the theme scheme.
class ThemeState {
  final Color seedColor;

  ThemeState({
    required this.seedColor,
  });

  ThemeState copyWith({
    Color? seedColor,
  }) {
    return ThemeState(
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

/// Controller responsible for managing and persisting user theme preferences 
/// such as light/dark mode and dynamic color seeding.
class ThemeController extends StateNotifier<ThemeState> {
  static const _seedColorKey = 'prism_seed_color';
  
  /// Default Seed: PRISM Navy (from original CivicHorizonTheme)
  static const Color defaultSeed = Color(0xFF00003C);

  ThemeController() : super(ThemeState(seedColor: defaultSeed)) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_seedColorKey) ?? defaultSeed.toARGB32();
    
    state = ThemeState(
      seedColor: Color(colorValue),
    );
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.toARGB32());
  }
}

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) => ThemeController());
