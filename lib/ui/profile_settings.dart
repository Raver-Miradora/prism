import 'package:flutter/material.dart';
import '../core/theme/civic_horizon_theme.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicHorizonTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEditorialHeader(),
                    const SizedBox(height: 32),
                    _buildProfileInformation(),
                    const SizedBox(height: 32),
                    _buildDataManagement(),
                    const SizedBox(height: 32),
                    _buildCommitChangesButton(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surface.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: CivicHorizonTheme.surfaceContainerHigh.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: CivicHorizonTheme.primary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              const Text(
                'PRISM',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: CivicHorizonTheme.primary,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CivicHorizonTheme.primary.withOpacity(0.1), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCeM6aIav-nn7Zz0BgE-xsOhebnAAq67qlz8-GZxxEEEHBnIJu1kDVjqnq2ffBz0x3YA2XoV1TK_5C7FBZKQqPHWrDEd3uk9zAS2shD4cGZeap5zhQVZKIoYhL_JtMuYlrfRNU9HGwAPWxrIl-9rt26gAS3y9t4kQVWGdkq1i0zf4LIdwKc61n8WGwlQrFojVo7NjU-k4FQNhCqQp21DmRC02toeE52aWIBwaggd_W_IMIbAgAXD8foPEAnqaVVAcQeP7tbMnrLrGQ'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'REGISTRY PROFILE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: CivicHorizonTheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: CivicHorizonTheme.primary,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInformation() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextInput('INTERN FULL NAME', 'Alexander Thorne'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextInput('GOVERNMENT AGENCY/OFFICE', 'Department of Information Technology')),
              const SizedBox(width: 24),
              Expanded(child: _buildTextInput('SUPERVISOR NAME', 'Dr. Elena Rodriguez')),
            ],
          ),
          const SizedBox(height: 32),
          _buildNumericInput('TOTAL TARGET HOURS', '486', Icons.schedule),
          const SizedBox(height: 24),
          _buildNumericInput('EXPECTED TIME IN', '08:00 AM', Icons.alarm),
        ],
      ),
    );
  }

  Widget _buildTextInput(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: CivicHorizonTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CivicHorizonTheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: CivicHorizonTheme.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _focusedInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericInput(String label, String initialValue, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: CivicHorizonTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CivicHorizonTheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: CivicHorizonTheme.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(icon, color: CivicHorizonTheme.onSurfaceVariant),
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _focusedInputBorder(),
          ),
        ),
      ],
    );
  }

  InputBorder _inputBorder() {
    return const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black12, width: 2),
      borderRadius: BorderRadius.zero,
    );
  }

  InputBorder _focusedInputBorder() {
    return const UnderlineInputBorder(
      borderSide: BorderSide(color: CivicHorizonTheme.primary, width: 2),
      borderRadius: BorderRadius.zero,
    );
  }

  Widget _buildDataManagement() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicHorizonTheme.outlineVariant.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CivicHorizonTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storage, color: CivicHorizonTheme.primary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Data Management',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CivicHorizonTheme.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'System-wide backup and recovery protocols',
                    style: TextStyle(
                      fontSize: 14,
                      color: CivicHorizonTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDataButton(Icons.cloud_upload, 'Backup Database')),
              const SizedBox(width: 16),
              Expanded(child: _buildDataButton(Icons.settings_backup_restore, 'Restore Database')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        side: const BorderSide(color: CivicHorizonTheme.outlineVariant, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        foregroundColor: CivicHorizonTheme.onSurfaceVariant,
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildCommitChangesButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          backgroundColor: CivicHorizonTheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: CivicHorizonTheme.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'COMMIT CHANGES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home'),
              _buildNavItem(Icons.edit_note, 'Journal'),
              _buildNavItem(Icons.analytics, 'Reports'),
              _buildNavItem(Icons.settings, 'Settings', isActive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    final color = isActive ? CivicHorizonTheme.primary : const Color(0xFF94A3B8);
    final bgColor = isActive ? CivicHorizonTheme.primary.withOpacity(0.1) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
