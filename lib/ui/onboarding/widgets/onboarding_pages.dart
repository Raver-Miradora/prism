import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/civic_horizon_theme.dart';
import '../../../controllers/onboarding_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    const String logoPath = 'C:/Users/User/.gemini/antigravity/brain/488b41bf-ecb6-465b-8604-7b6f7b41ac08/prism_logo_1774766315620.png';
    const String heroImagePath = 'C:/Users/User/.gemini/antigravity/brain/fddd80e3-ee58-430b-b0d4-4d65da4e1f32/onboarding_hero_hourglass_1774760000704.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(logoPath), fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 32),
          // Hero Component
          Container(
            height: 280,
            decoration: BoxDecoration(
              boxShadow: CivicHorizonTheme.staticAmbientGlow(),
            ),
            child: Image.file(
              File(heroImagePath),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          // Header Component
          const Text(
            'Welcome to PRISM.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w900,
              fontSize: 38,
              color: CivicHorizonTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          // Body Component
          const Text(
            'Your digital registry for a hassle-free deployment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              color: CivicHorizonTheme.onSurfaceVariant,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage2 extends ConsumerStatefulWidget {
  const OnboardingPage2({super.key});

  @override
  ConsumerState<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends ConsumerState<OnboardingPage2> {
  bool _isCapturing = false;

  Future<void> _captureLocation() async {
    setState(() => _isCapturing = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        ref.read(onboardingProvider.notifier).updateOfficeLocation(position.latitude, position.longitude);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Office location captured successfully!'), backgroundColor: CivicHorizonTheme.tertiaryFixedDim),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error capturing location.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    final List<String> departments = [
      'Office of the Mayor',
      'Office of the Vice Mayor',
      'Municipal Administrator Office',
      'Human Resource Management Office (HRMO)',
      'Municipal Treasurer’s Office (MTO)',
      'Municipal Assessor’s Office',
      'Municipal Accounting Office',
      'Municipal Budget Office (MBO)',
      'Municipal Civil Registrar (MCR)',
      'Municipal Social Welfare and Development Office (MSWDO)',
      'Municipal Agriculture Office',
      'Municipal Environment and Natural Resources Office (MENRO)',
      'Municipal Disaster Risk Reduction and Management Office (MDRRMO)',
      'Public Employment Service Office (PESO)',
      'Other',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Let's build your profile.",
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w900,
                fontSize: 46,
                color: CivicHorizonTheme.primary,
              ),
            ),
            const SizedBox(height: 48),
            
            // Name Input
            _buildInputLabel('FULL NAME (AS IT APPEARS ON OFFICIAL DOCS)'),
            const SizedBox(height: 12),
            TextField(
              onChanged: notifier.updateName,
              decoration: _inputDecoration('e.g. Juan De La Cruz', Icons.person_outline),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Office GPS Capture
            _buildInputLabel('OFFICE BASE LOCATION (REQUIRED FOR GEOFENCING)', isRequired: true),
            const SizedBox(height: 12),
            InkWell(
              onTap: _isCapturing ? null : _captureLocation,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.officeLat != null ? CivicHorizonTheme.tertiaryFixed.withAlpha(30) : CivicHorizonTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.officeLat != null ? CivicHorizonTheme.tertiaryFixedDim : CivicHorizonTheme.outlineVariant.withAlpha(50),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.officeLat != null ? Icons.location_on : Icons.location_searching,
                      color: state.officeLat != null ? CivicHorizonTheme.onTertiaryFixedVariant : CivicHorizonTheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.officeLat != null ? 'Location Locked' : 'Capture Current Location',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            state.officeLat != null 
                              ? '${state.officeLat!.toStringAsFixed(4)}, ${state.officeLng!.toStringAsFixed(4)}' 
                              : 'Tap to set office coordinates',
                            style: TextStyle(fontSize: 12, color: CivicHorizonTheme.onSurfaceVariant.withAlpha(150)),
                          ),
                        ],
                      ),
                    ),
                    if (_isCapturing)
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Department Head Input
            _buildInputLabel('NAME OF DEPARTMENT HEAD / SUPERVISOR'),
            const SizedBox(height: 12),
            TextField(
              onChanged: notifier.updateSupervisorName,
              decoration: _inputDecoration('e.g. Atty. Maria Santos', Icons.supervisor_account_outlined),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // Office Dropdown
            _buildInputLabel('OFFICIAL DEPARTMENT ASSIGNMENT', isRequired: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: departments.contains(state.office) ? state.office : 'Other',
              decoration: _inputDecoration('Select assignment', Icons.business_outlined),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: CivicHorizonTheme.primary),
              items: departments
                  .map((off) => DropdownMenuItem(
                    value: off, 
                    child: Text(
                      off, 
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    )
                  ))
                  .toList(),
              onChanged: (val) {
                if (val != null) notifier.updateOffice(val);
              },
            ),

            if (state.office == 'Other') ...[
              const SizedBox(height: 24),
              _buildInputLabel('SPECIFY YOUR DEPARTMENT'),
              const SizedBox(height: 12),
              TextField(
                onChanged: notifier.updateCustomOffice,
                decoration: _inputDecoration('Type your department name...', Icons.edit_note),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: CivicHorizonTheme.onSurfaceVariant, letterSpacing: 1.0),
        ),
        if (isRequired)
          const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: CivicHorizonTheme.onSurfaceVariant),
      filled: true,
      fillColor: CivicHorizonTheme.surfaceContainerLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: CivicHorizonTheme.outlineVariant.withAlpha(50))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    );
  }
}

class OnboardingPage3 extends ConsumerStatefulWidget {
  const OnboardingPage3({super.key});

  @override
  ConsumerState<OnboardingPage3> createState() => OnboardingPage3State();
}

class OnboardingPage3State extends ConsumerState<OnboardingPage3> {
  final ScrollController _scrollController = ScrollController();

  void focusHours() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What is your mission?",
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w900,
              fontSize: 46,
              color: CivicHorizonTheme.primary,
            ),
          ),
          const SizedBox(height: 40),
          
          Expanded(
            child: ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              children: [
                _ProgramCard(
                  type: 'OJT',
                  title: 'OJT',
                  body: 'Standard University Academic Requirement',
                  isSelected: state.programType == 'OJT',
                  onTap: () => notifier.selectProgram('OJT'),
                ),
                const SizedBox(height: 16),
                _ProgramCard(
                  type: 'SPES',
                  title: 'SPES',
                  body: 'Special Program for Employment of Students (DOLE)',
                  isSelected: state.programType == 'SPES',
                  onTap: () => notifier.selectProgram('SPES'),
                ),
                const SizedBox(height: 16),
                _ProgramCard(
                  type: 'GIP',
                  title: 'DOLE GIP',
                  body: 'Government Internship Program (National/Regional)',
                  isSelected: state.programType == 'GIP',
                  onTap: () => notifier.selectProgram('GIP'),
                ),
                const SizedBox(height: 16),
                _ProgramCard(
                  type: 'Immersion',
                  title: 'Immersion',
                  body: 'SHS Work Immersion Requirement (80 Hours)',
                  isSelected: state.programType == 'Immersion',
                  onTap: () => notifier.selectProgram('Immersion'),
                ),
                const SizedBox(height: 32),

                // Manual Hours Field
                const Text(
                  'ADJUST TOTAL REQUIRED HOURS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: CivicHorizonTheme.onSurfaceVariant, letterSpacing: 1.0),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (state.programType == 'OJT' && !state.hasAdjustedHours) 
                        ? Colors.orange 
                        : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.timer_outlined, size: 20, color: CivicHorizonTheme.primary),
                      suffixText: 'Hours',
                      suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: CivicHorizonTheme.primary),
                      filled: true,
                      fillColor: CivicHorizonTheme.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: CivicHorizonTheme.outlineVariant.withAlpha(50))),
                    ),
                    controller: TextEditingController(text: state.targetHours.toString())..selection = TextSelection.fromPosition(TextPosition(offset: state.targetHours.toString().length)),
                    onChanged: (val) {
                      final hrs = int.tryParse(val);
                      if (hrs != null) notifier.updateTargetHours(hrs);
                    },
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: CivicHorizonTheme.primary),
                  ),
                ),
                if (state.programType == 'OJT' && !state.hasAdjustedHours)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please verify your curriculum hours before proceeding.',
                      style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final String type;
  final String title;
  final String body;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.type,
    required this.title,
    required this.body,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? CivicHorizonTheme.tertiaryFixedDim.withAlpha(50) : CivicHorizonTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
            ? Border.all(color: CivicHorizonTheme.tertiaryFixedDim, width: 2)
            : Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(50)),
          boxShadow: isSelected ? [BoxShadow(color: CivicHorizonTheme.tertiaryFixedDim.withAlpha(50), blurRadius: 20)] : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? CivicHorizonTheme.tertiaryFixedDim : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.track_changes, size: 20, color: isSelected ? Colors.white : CivicHorizonTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? CivicHorizonTheme.onTertiaryFixedVariant : CivicHorizonTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.w500,
                      color: isSelected ? CivicHorizonTheme.onTertiaryFixedVariant.withAlpha(180) : CivicHorizonTheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage4 extends ConsumerStatefulWidget {
  const OnboardingPage4({super.key});

  @override
  ConsumerState<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends ConsumerState<OnboardingPage4> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 20) {
      ref.read(onboardingProvider.notifier).setTermsRead(true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Data Privacy & Terms.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w900,
              fontSize: 38,
              color: CivicHorizonTheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CivicHorizonTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: CivicHorizonTheme.outlineVariant.withAlpha(50)),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acknowledgement of Data Privacy & Terms of Use',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: CivicHorizonTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Before initializing your local registry and hour tracking, please read and acknowledge the following terms regarding your data and usage of this companion tool.',
                      style: TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _termsSection(
                      '1. Data Processing and Local Storage',
                      'PRISM is an "offline-first" application. All personal data you input (Name, Program Type), your geolocated time logs (GPS coordinates, time-stamps), and task photos are processed and stored locally on your personal device using a secure SQLite database. This data is not synchronized to an external cloud database or LGU server.',
                    ),
                    const SizedBox(height: 16),
                    _termsSection(
                      '2. Data Privacy Act of 2012 Compliance',
                      'While the data remains on your device, we process this information adhering to the core principles of the Philippine Data Privacy Act of 2012 (R.A. 10173). We collect this data solely to fulfill the system\'s function of generating accurate Daily Time Records (Form 48) and Accomplishment Reports on your behalf.',
                    ),
                    const SizedBox(height: 16),
                    _termsSection(
                      '3. User Accountability for Input',
                      'You warrant that all time logs, task descriptions, and location data input into this app are truthful and accurate. Providing false, forged, or "buddy-punched" time entries is a violation of government integrity standards and may result in disciplinary action from your university or the LGU.',
                    ),
                    const SizedBox(height: 16),
                    _termsSection(
                      '4. Limit of Liability',
                      'PRISM is a productivity helper tool designed to format your records. The final generated PDFs require human verification and physical signatures from authorized LGU supervisors and HRMO/PESO staff to be considered valid for submission to CSC or DOLE.',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'By clicking "Accept & Enter Dashboard," you confirm that you have read, understood, and accept these data privacy standards and usage terms.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: CivicHorizonTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _termsSection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: CivicHorizonTheme.primary),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: const TextStyle(fontSize: 12, height: 1.5),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
