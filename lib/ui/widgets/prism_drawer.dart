import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/civic_horizon_theme.dart';
import '../../controllers/settings_controller.dart';

class PrismDrawer extends ConsumerWidget {
  const PrismDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We optionally watch settingsProvider, but if someone is on another tab it should ideally be alive.
    // If we just mapped settingsProvider everywhere, it acts as a global singleton.
    final state = ref.watch(settingsProvider);
    final profile = state.profile;
    
    final bool hasImage = profile?.profileImagePath != null && profile!.profileImagePath!.isNotEmpty;
    final String displayName = (profile?.name != null && profile!.name.isNotEmpty) 
        ? profile.name 
        : 'PRISM Intern';

    return Drawer(
      backgroundColor: CivicHorizonTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: CivicHorizonTheme.surfaceContainerLow),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CivicHorizonTheme.primaryContainer,
                      image: hasImage 
                        ? DecorationImage(image: FileImage(File(profile.profileImagePath!)), fit: BoxFit.cover)
                        : null,
                    ),
                    child: hasImage ? null : const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.bold, fontSize: 18, color: CivicHorizonTheme.primary, letterSpacing: -0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Active Registry',
                          style: TextStyle(fontSize: 12, color: CivicHorizonTheme.onSurfaceVariant, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDrawerTile(Icons.info_outline, 'About PRISM', true, onTap: () {}),
            _buildDrawerTile(Icons.policy_outlined, 'CSC Form Guidelines', false, onTap: () {}),
            _buildDrawerTile(Icons.bug_report_outlined, 'Report Issue', false, onTap: () {}),
            const Divider(color: CivicHorizonTheme.surfaceContainerHigh, height: 32),
            _buildDrawerTile(
              Icons.lock, 
              'Lock Session', 
              false, 
              color: CivicHorizonTheme.error,
              onTap: () {
                // Instantly exit / suspend app as a security lock mechanism.
                SystemNavigator.pop();
              }
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('VERSION 1.0.0', style: TextStyle(color: CivicHorizonTheme.outlineVariant, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Camarines Sur, Philippines', style: TextStyle(color: CivicHorizonTheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String title, bool isActive, {Color? color, required VoidCallback onTap}) {
    final c = color ?? (isActive ? CivicHorizonTheme.primary : CivicHorizonTheme.onSurfaceVariant);
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          color: c,
        ),
      ),
      onTap: onTap,
    );
  }
}
