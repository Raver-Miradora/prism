import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/civic_horizon_theme.dart';
import '../../controllers/settings_controller.dart';

class PrismDrawer extends ConsumerWidget {
  const PrismDrawer({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About PRISM', style: TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary)),
        content: const Text(
          'PRISM (Program Registry for Intern and Student Management) is an offline-first '
          'timeclock and reporting system strictly designed for government internship monitoring '
          'compliance. It calculates your CSC DTR Form 48 metrics directly on-device.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showGuidelinesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CSC Form Guidelines', style: TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary)),
        content: const SingleChildScrollView(
          child: Text(
            '1. A maximum of 8 hours per day is credited.\n\n'
            '2. Tardiness and Undertimes are aggregated dynamically and deducted from your target hours.\n\n'
            '3. At least 1 hour must be strictly allotted for lunch breaks between AM and PM shifts.\n\n'
            '4. A generated signature must be explicitly verified upon generating the PDF.\n\n'
            '5. Falsification of records constitutes a violation of CSC protocol.',
            style: TextStyle(height: 1.5, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Acknowledge')),
        ],
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: Can I edit my past logs?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: You must submit a Journal correction request. Direct database modification is locked to preserve integrity.\n'),
              Text('Q: Does PRISM require internet?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: No. PRISM is an offline-first architecture. It syncs locally using SQLite.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showIssueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report an Issue', style: TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Encountered an error or need technical assistance? Reach out to the developer directly:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: CivicHorizonTheme.primary),
              title: const Text('ravemiradora@gmail.com', style: TextStyle(fontSize: 13, decoration: TextDecoration.underline, color: CivicHorizonTheme.primary)),
              onTap: () => launchUrl(Uri.parse('mailto:ravemiradora@gmail.com')),
            ),
            ListTile(
              leading: const Icon(Icons.facebook, color: CivicHorizonTheme.primary),
              title: const Text('Rave Miradora', style: TextStyle(fontSize: 13, decoration: TextDecoration.underline, color: CivicHorizonTheme.primary)),
              onTap: () => launchUrl(Uri.parse('https://www.facebook.com/ra.ve.52687506')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _buildDrawerTile(Icons.info_outline, 'About PRISM', true, onTap: () => _showAboutDialog(context)),
            _buildDrawerTile(Icons.policy_outlined, 'CSC Form Guidelines', false, onTap: () => _showGuidelinesDialog(context)),
            _buildDrawerTile(Icons.bug_report_outlined, 'Report Issue', false, onTap: () => _showIssueDialog(context)),
            _buildDrawerTile(Icons.help_outline, 'FAQ', false, onTap: () => _showFAQDialog(context)),
            
            const Divider(color: CivicHorizonTheme.surfaceContainerHigh, height: 32),
            _buildDrawerTile(
              Icons.logout, 
              'Log Out', 
              false, 
              color: CivicHorizonTheme.error,
              onTap: () {
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
