import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/civic_horizon_theme.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/theme_controller.dart';

class PrismDrawer extends ConsumerWidget {
  const PrismDrawer({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('About PRISM', style: context.text.headlineMedium?.copyWith(color: context.colors.primary)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('What is PRISM?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text(
                'PRISM (Program Registry for Intern and Student Management) is a secure, offline-first '
                'companion app built exclusively for government interns, SPES beneficiaries, GIPs, and '
                'Immersion students.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text('Our Mission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text(
                'We believe public service training should focus on skill-building, not tedious paperwork. '
                'PRISM automates the administrative burden of local government internships. By seamlessly '
                'tracking attendance and utilizing AI to draft Civil Service Commission (CSC) compliant '
                'accomplishment reports, PRISM empowers students to take control of their training experience.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text('About the Developer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text(
                'PRISM was engineered by Raver B. Miradora, a graduating BS Information Technology student at '
                'Partido State University. The architecture for this system was built directly from frontline '
                'experience, observing real-world administrative bottlenecks while interning at the Local '
                'Government Unit of Lagonoy under the HRMO and PESO.\n\n'
                'Combining local government workflow knowledge with cross-platform mobile development, '
                'Raver\u2014a Career Service Professional eligible and aspiring Associate AI Engineer designed '
                'PRISM to bridge the gap between traditional government requirements and modern, AI-driven technology.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
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
        title: Text('CSC Form Guidelines', style: context.text.headlineMedium?.copyWith(color: context.colors.primary)),
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
        title: Text('Frequently Asked Questions', style: context.text.headlineMedium?.copyWith(color: context.colors.primary)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: Can I edit my past logs?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: You must submit a Journal correction request. Direct database modification is locked to preserve integrity.\n'),
              Text('Q: Does PRISM require internet?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: No. PRISM is an offline-first architecture. It syncs locally using SQLite.\n'),
              Text('Q: How is the formal report generated?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: PRISM uses a built-in AI engine that transforms your informal daily notes into a CSC-compliant formal report.\n'),
              Text('Q: Can I export my reports?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Yes. You can assemble a DTR PDF from the Reports tab, or export monthly formal reports from the Journal section.'),
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
        title: Text('Report an Issue', style: context.text.headlineMedium?.copyWith(color: context.colors.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Encountered an error or need technical assistance? Reach out to the developer directly:'),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email, color: context.colors.primary),
              title: Text('ravemiradora@gmail.com', style: TextStyle(fontSize: 13, decoration: TextDecoration.underline, color: context.colors.primary)),
              onTap: () => launchUrl(Uri.parse('mailto:ravemiradora@gmail.com')),
            ),
            ListTile(
              leading: Icon(Icons.facebook, color: context.colors.primary),
              title: Text('Raver Miradora', style: TextStyle(fontSize: 13, decoration: TextDecoration.underline, color: context.colors.primary)),
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
    final themeState = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);
    final profile = state.profile;
    
    final bool hasImage = profile?.profileImagePath != null && profile!.profileImagePath!.isNotEmpty;
    final String displayName = (profile?.name != null && profile!.name.isNotEmpty) 
        ? profile.name 
        : 'PRISM Intern';

    return Drawer(
      backgroundColor: context.colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: context.colors.surfaceContainerLow),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.primaryContainer,
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
                          style: context.text.headlineSmall?.copyWith(fontSize: 18, color: context.colors.primary, letterSpacing: -0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Active Registry',
                          style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDrawerTile(context, Icons.info_outline, 'About PRISM', true, onTap: () => _showAboutDialog(context)),
            _buildDrawerTile(context, Icons.policy_outlined, 'CSC Form Guidelines', false, onTap: () => _showGuidelinesDialog(context)),
            _buildDrawerTile(context, Icons.bug_report_outlined, 'Report Issue', false, onTap: () => _showIssueDialog(context)),
            _buildDrawerTile(context, Icons.help_outline, 'FAQ', false, onTap: () => _showFAQDialog(context)),
            
            const Divider(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dark_mode, color: context.colors.onSurfaceVariant, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Dark Mode',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Switch(
                    value: themeState.themeMode == ThemeMode.dark,
                    onChanged: (val) => themeNotifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
                    activeThumbColor: context.colors.primary,
                  ),
                ],
              ),
            ),

            _buildDrawerTile(
              context,
              Icons.logout, 
              'Log Out', 
              false, 
              color: context.colors.error,
              onTap: () {
                SystemNavigator.pop();
              }
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VERSION 1.0.0', style: TextStyle(color: context.colors.outline, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Camarines Sur, Philippines', style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(BuildContext context, IconData icon, String title, bool isActive, {Color? color, required VoidCallback onTap}) {
    final c = color ?? (isActive ? context.colors.primary : context.colors.onSurfaceVariant);
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
