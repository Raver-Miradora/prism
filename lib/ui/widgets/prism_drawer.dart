import 'package:flutter/material.dart';
import '../../core/theme/civic_horizon_theme.dart';

class PrismDrawer extends StatelessWidget {
  const PrismDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CivicHorizonTheme.primaryContainer,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'PRISM Intern',
                        style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.bold, fontSize: 18, color: CivicHorizonTheme.primary, letterSpacing: -0.5),
                      ),
                      Text(
                        'Active Registry',
                        style: TextStyle(fontSize: 12, color: CivicHorizonTheme.onSurfaceVariant, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDrawerTile(Icons.info_outline, 'About PRISM', true),
            _buildDrawerTile(Icons.policy_outlined, 'CSC Form Guidelines', false),
            _buildDrawerTile(Icons.bug_report_outlined, 'Report Issue', false),
            const Divider(color: CivicHorizonTheme.surfaceContainerHigh, height: 32),
            _buildDrawerTile(Icons.logout, 'Lock Session', false, color: CivicHorizonTheme.error),
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

  Widget _buildDrawerTile(IconData icon, String title, bool isActive, {Color? color}) {
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
      onTap: () {},
    );
  }
}
