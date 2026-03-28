import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../core/theme/civic_horizon_theme.dart';
import '../core/database/database_helper.dart';
import '../controllers/settings_controller.dart';
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
      const SnackBar(content: Text('Settings successfully saved to registry.'), backgroundColor: CivicHorizonTheme.primary),
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
      backgroundColor: CivicHorizonTheme.background,
      drawer: const PrismDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(state),
            Expanded(
              child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
    );
  }

  Widget _buildTopAppBar(SettingsState state) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surface.withAlpha(216),
        border: Border(
          bottom: BorderSide(
            color: CivicHorizonTheme.surfaceContainerHigh.withAlpha(127),
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
                  icon: const Icon(Icons.menu, color: CivicHorizonTheme.primary),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
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
          GestureDetector(
            onTap: () => ref.read(settingsProvider.notifier).pickImage(),
            child: const ProfileAvatar(size: 44),
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
          _buildTextInput('INTERN FULL NAME', _nameController),
          const SizedBox(height: 24),
          // Fix right overflow by utilizing a Wrap instead of Row with Expandeds for potentially narrow mobile screens
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(width: 320, child: _buildTextInput('GOVERNMENT AGENCY/OFFICE', _agencyController)),
              SizedBox(width: 320, child: _buildTextInput('SUPERVISOR NAME', _supervisorController)),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(width: 320, child: _buildNumericInput('TOTAL TARGET HOURS', _hoursController, Icons.schedule)),
              SizedBox(width: 320, child: _buildNumericInput('EXPECTED TIME IN', _timeInController, Icons.alarm)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
          controller: controller,
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

  Widget _buildNumericInput(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
          controller: controller,
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
        border: Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(25)),
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
                  color: CivicHorizonTheme.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storage, color: CivicHorizonTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
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
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Fix Right Overflow: Stack buttons or wrap them
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildDataButton(Icons.cloud_upload, 'Backup Database', onTap: _backupDatabase),
              _buildDataButton(Icons.settings_backup_restore, 'Restore Database', onTap: _restoreDatabase),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataButton(IconData icon, String label, {required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
        onPressed: _commitChanges,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          backgroundColor: CivicHorizonTheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: CivicHorizonTheme.primary.withAlpha(127),
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
