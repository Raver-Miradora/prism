import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/civic_horizon_theme.dart';
import '../../../controllers/onboarding_controller.dart';
import 'widgets/onboarding_pages.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<OnboardingPage3State> _page3Key = GlobalKey<OnboardingPage3State>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final state = ref.read(onboardingProvider);
    
    // Page 3 OJT Validation: Prompt to see 'adjust hours' field
    if (state.currentIndex == 2 && state.programType == 'OJT' && !state.hasAdjustedHours) {
       _page3Key.currentState?.focusHours();
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Please verify and adjust your required OJT hours.'),
           backgroundColor: Colors.orange,
         ),
       );
       return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: CivicHorizonTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => ref.read(onboardingProvider.notifier).updateIndex(index),
                children: [
                  const OnboardingPage1(),
                  const OnboardingPage2(),
                  OnboardingPage3(key: _page3Key),
                  const OnboardingPage4(),
                ],
              ),
            ),
            _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(OnboardingState state) {
    final isLastPage = state.currentIndex == 3;
    final isFirstPage = state.currentIndex == 0;

    // Validation logic
    bool isNextDisabled = false;
    
    if (state.currentIndex == 1) {
      // Page 2: Name, Office, and GPS
      final hasName = state.name.trim().isNotEmpty;
      final hasOffice = state.office.isNotEmpty;
      final hasCustomOffice = state.office != 'Other' || (state.customOffice?.trim().isNotEmpty ?? false);
      final hasGps = state.officeLat != null;
      
      if (!hasName || !hasOffice || !hasCustomOffice || !hasGps) {
        isNextDisabled = true;
      }
    } else if (isLastPage) {
      // Page 4: Terms
      if (!state.hasReadTerms) {
        isNextDisabled = true;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildIndicator(index == state.currentIndex)),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              if (!isFirstPage)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: CivicHorizonTheme.outlineVariant, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: CivicHorizonTheme.primary,
                    ),
                    child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              if (!isFirstPage) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isNextDisabled ? 0.5 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: (isLastPage || isNextDisabled) ? null : CivicHorizonTheme.staticCtaGradient(),
                      color: isLastPage 
                        ? (isNextDisabled ? CivicHorizonTheme.outlineVariant : CivicHorizonTheme.tertiaryFixedDim)
                        : (isNextDisabled ? CivicHorizonTheme.outlineVariant : null),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isNextDisabled ? [] : [
                        BoxShadow(
                          color: (isLastPage ? CivicHorizonTheme.tertiaryFixedDim : CivicHorizonTheme.primary).withAlpha(80),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isNextDisabled 
                        ? null 
                        : (isLastPage 
                          ? () => ref.read(onboardingProvider.notifier).completeOnboarding()
                          : _nextPage),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Center(
                        child: Text(
                          isFirstPage ? 'Get Started' : (isLastPage ? 'Accept & Enter Dashboard' : 'Next'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? CivicHorizonTheme.primary : CivicHorizonTheme.outlineVariant.withAlpha(80),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
