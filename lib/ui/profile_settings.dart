import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../core/theme/civic_horizon_theme.dart';
import '../core/database/database_helper.dart';
import '../controllers/settings_controller.dart';
import '../controllers/theme_controller.dart';
import 'widgets/prism_drawer.dart';
import 'widgets/profile_avatar.dart';

class ProfileSettings extends ConsumerStatefulWidget {
  const ProfileSettings({super.key});

  @override
  ConsumerState<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends ConsumerState<ProfileSettings> {
  late TextEditingController _nameController;
  late TextEditingController _agencyController;
  late TextEditingController _supervisorController;
  late TextEditingController _hoursController;
  late TextEditingController _timeInController;
  bool _hasPopulated = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _agencyController = TextEditingController();
    _supervisorController = TextEditingController();
    _hoursController = TextEditingController();
    _timeInController = TextEditingController();
  }

  void _populateControllers(SettingsState state) {
    if (_hasPopulated) return;
    if (state.isLoading) return;
    _hasPopulated = true;
    if (state.profile != null) {
      _nameController.text = state.profile!.name;
      _agencyController.text = state.profile!.agencyOffice;
      _supervisorController.text = state.profile!.supervisorName;
    }
    if (state.settings != null) {
      _hoursController.text = state.settings!.targetHours.toString();
      _timeInController.text = state.settings!.expectedTimeIn;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _agencyController.dispose();
    _supervisorController.dispose();
    _hoursController.dispose();
    _timeInController.dispose();
    super.dispose();
  }

  void _commitChanges() {
    FocusScope.of(context).unfocus();
    ref.read(settingsProvider.notifier).saveSettings(
      name: _nameController.text,
      agency: _agencyController.text,
      supervisor: _supervisorController.text,
      targetHours: int.tryParse(_hoursController.text) ?? 486,
      timeIn: _timeInController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Settings successfully saved to registry.'), backgroundColor: context.colors.primary),
    );
  }

  Future<void> _backupDatabase() async {
    try {
      final dbFolder = await getDatabasesPath();
      final File sourceFile = File(p.join(dbFolder, 'prism.db'));
      
      final docDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(p.join(docDir.path, 'PRISM_Backups'));
      if (!await backupDir.exists()) await backupDir.create();
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final backupFile = File(p.join(backupDir.path, 'prism_backup_$timestamp.db'));
      
      await sourceFile.copy(backupFile.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup successful: ${backupFile.path}'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup failed: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _restoreDatabase() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(p.join(docDir.path, 'PRISM_Backups'));
      if (!await backupDir.exists()) {
        throw Exception("No backups found");
      }
      
      final List<FileSystemEntity> files = backupDir.listSync().where((f) => f.path.endsWith('.db')).toList();
      if (files.isEmpty) throw Exception("No backups found");
      
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      final latestBackup = File(files.first.path);
      
      final dbFolder = await getDatabasesPath();
      final targetFile = File(p.join(dbFolder, 'prism.db'));
      
      // Close active DB, overwrite, the app needs restart ideally but we'll try raw copy
      await DatabaseHelper.instance.close();
      await latestBackup.copy(targetFile.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore successful! Restart app to apply.'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    // Populate TextEditingControllers when data arrives
    _populateControllers(state);

    return Scaffold(
      backgroundColor: context.colors.surface,
      drawer: const PrismDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context, state),
            Expanded(
              child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildEditorialHeader(context),
                        const SizedBox(height: 32),
                        _buildProfileInformation(context),
                        const SizedBox(height: 32),
                        _buildPersonalization(context),
                        const SizedBox(height: 32),
                        _buildCommitChangesButton(context),
                        const SizedBox(height: 32),
                        _buildDataManagement(context),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, SettingsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surface.withAlpha(216),
        border: Border(
          bottom: BorderSide(
            color: context.colors.surfaceContainerHigh.withAlpha(127),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: context.colors.primary),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PRISM',
                style: context.text.headlineLarge?.copyWith(fontSize: 20, letterSpacing: -1.0),
              ),
            ],
          ),
          ProfileAvatar(
            size: 44,
            onTapOverride: () => ref.read(settingsProvider.notifier).pickImage(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REGISTRY PROFILE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Settings',
          style: context.text.displayMedium?.copyWith(fontSize: 36, letterSpacing: -1.0),
        ),
      ],
    );
  }

  Widget _buildProfileInformation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextInput(context, 'INTERN FULL NAME', _nameController),
          const SizedBox(height: 24),
          // Fix right overflow by utilizing a Wrap instead of Row with Expandeds for potentially narrow mobile screens
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(width: 320, child: _buildTextInput(context, 'GOVERNMENT AGENCY/OFFICE', _agencyController)),
              SizedBox(width: 320, child: _buildTextInput(context, 'SUPERVISOR NAME', _supervisorController)),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(width: 320, child: _buildNumericInput(context, 'TOTAL TARGET HOURS', _hoursController, Icons.schedule)),
              SizedBox(width: 320, child: _buildNumericInput(context, 'EXPECTED TIME IN', _timeInController, Icons.alarm)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalization(BuildContext context) {
    final themeState = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);

    final List<Color> seedColors = [
      const Color(0xFF0D47A1), // Deep Blue
      const Color(0xFF1B5E20), // Emerald Green
      const Color(0xFF4A148C), // Royal Purple
      const Color(0xFFBF360C), // Sunset Orange
      const Color(0xFF006064), // Teal
      const Color(0xFF311B92), // Indigo
    ];

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERSONALIZATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Accent Color Scheme',
            style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: context.colors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a primary color to seed the system theme',
            style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: seedColors.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final color = seedColors[index];
                final isSelected = themeState.seedColor.value == color.value;

                return GestureDetector(
                  onTap: () => themeNotifier.setSeedColor(color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? context.colors.onSurface : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.colors.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.colors.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: _inputBorder(context),
            enabledBorder: _inputBorder(context),
            focusedBorder: _focusedInputBorder(context),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericInput(BuildContext context, String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.colors.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(icon, color: context.colors.onSurfaceVariant),
            border: _inputBorder(context),
            enabledBorder: _inputBorder(context),
            focusedBorder: _focusedInputBorder(context),
          ),
        ),
      ],
    );
  }

  InputBorder _inputBorder(BuildContext context) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: context.colors.outlineVariant, width: 2),
      borderRadius: BorderRadius.zero,
    );
  }

  InputBorder _focusedInputBorder(BuildContext context) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: context.colors.primary, width: 2),
      borderRadius: BorderRadius.zero,
    );
  }

  Widget _buildDataManagement(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant.withAlpha(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: context.colors.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.storage, color: context.colors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Management',
                      style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: context.colors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'System-wide backup and recovery protocols',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Fix Right Overflow: Stack buttons or wrap them
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDataButton(context, Icons.cloud_upload, 'Backup Database', onTap: _backupDatabase),
                _buildDataButton(context, Icons.settings_backup_restore, 'Restore Database', onTap: _restoreDatabase),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataButton(BuildContext context, IconData icon, String label, {required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        side: BorderSide(color: context.colors.outlineVariant, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        foregroundColor: context.colors.onSurfaceVariant,
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildCommitChangesButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _commitChanges,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.onPrimary,
          elevation: 8,
          shadowColor: context.colors.primary.withAlpha(127),
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
}
