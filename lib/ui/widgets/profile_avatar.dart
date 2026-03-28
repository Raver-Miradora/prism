import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/civic_horizon_theme.dart';
import '../../controllers/settings_controller.dart';
import '../main_shell.dart';

/// A shared profile avatar widget that reads from settingsProvider.
/// All pages (Home, Journal, Reports, Settings) use this so the image is always in sync.
/// By default, tapping navigates to the Settings tab (index 3).
/// Pass [onTapOverride] to supply custom tap behavior (e.g. image picker on the Settings page).
class ProfileAvatar extends ConsumerWidget {
  final double size;
  final VoidCallback? onTapOverride;
  const ProfileAvatar({super.key, this.size = 40, this.onTapOverride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final profile = state.profile;
    final bool hasImage = profile?.profileImagePath != null && profile!.profileImagePath!.isNotEmpty;

    return GestureDetector(
      onTap: onTapOverride ?? () {
        // Default: navigate to Settings tab
        ref.read(navIndexProvider.notifier).state = 3;
      },
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CivicHorizonTheme.primaryContainer,
          border: Border.all(color: CivicHorizonTheme.primary.withAlpha(40), width: 2),
          image: hasImage
              ? DecorationImage(
                  image: FileImage(File(profile.profileImagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasImage ? null : Icon(Icons.person, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
