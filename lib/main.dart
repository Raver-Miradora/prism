import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/civic_horizon_theme.dart';
import 'ui/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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

class PrismApp extends StatelessWidget {
  const PrismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRISM Timeclock',
      debugShowCheckedModeBanner: false,
      theme: CivicHorizonTheme.themeData,
      home: const MainShell(),
    );
  }
}
