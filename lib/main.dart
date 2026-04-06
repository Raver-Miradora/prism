import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/civic_horizon_theme.dart';
import 'ui/main_shell.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'controllers/settings_controller.dart';
import 'controllers/theme_controller.dart';

import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Strict Location Enforcement on Startup
  // This ensures the GPS is on before the user even sees the dashboard.
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }
  } catch (e) {
    debugPrint('Startup Location Check Error: $e');
  }

  // Lock to portrait mode for standard app experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Make system UI overlay transparent to match our "glassmorphism" app bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: PrismApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PrismApp extends ConsumerWidget {
  const PrismApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final themeState = ref.watch(themeControllerProvider);

    // Update status bar based on brightness (Always Light mode UI, Dark Icons)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PRISM Timeclock',
      debugShowCheckedModeBanner: false,
      theme: CivicHorizonTheme.light(themeState.seedColor),
      darkTheme: CivicHorizonTheme.light(themeState.seedColor), // Force light theme always
      themeMode: ThemeMode.light,
      home: _getHome(settingsState),
    );
  }

  Widget _getHome(SettingsState state) {
    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if onboarding is needed (name is empty or just default 'Intern')
    final isNewUser = state.profile == null || 
                      state.profile!.name.isEmpty || 
                      state.profile!.name == 'Intern';

    if (isNewUser) {
      return const OnboardingScreen();
    }

    return const MainShell();
  }
}
