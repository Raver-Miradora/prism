import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color seedColor;

  ThemeState({
    required this.themeMode,
    required this.seedColor,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

class ThemeController extends StateNotifier<ThemeState> {
  static const _themeModeKey = 'prism_theme_mode';
  static const _seedColorKey = 'prism_seed_color';
  
  // Default Seed: PRISM Navy (from original CivicHorizonTheme)
  static const Color defaultSeed = Color(0xFF00003C);

  ThemeController() : super(ThemeState(themeMode: ThemeMode.system, seedColor: defaultSeed)) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final modeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    final colorValue = prefs.getInt(_seedColorKey) ?? defaultSeed.value;
    
    state = ThemeState(
      themeMode: ThemeMode.values[modeIndex],
      seedColor: Color(colorValue),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.value);
  }

  void toggleDarkMode() {
    if (state.themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) => ThemeController());
