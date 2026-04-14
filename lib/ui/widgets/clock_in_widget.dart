import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/civic_horizon_theme.dart';
import '../../services/app_feedback.dart';

/// A specialized CTA button for PRISM that handles its own loading state, 
/// tactile haptic feedback, and standardized attendance success/error reporting.
class ClockInWidget extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final String title;
  final String overline;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isErrorStyle;

  const ClockInWidget({
    super.key,
    this.onPressed,
    required this.title,
    required this.overline,
    required this.icon,
    this.iconBgColor = const Color(0xFF00003C), // PRISM Deep Navy
    this.iconColor = Colors.white,
    this.isErrorStyle = false,
  });

  @override
  State<ClockInWidget> createState() => _ClockInWidgetState();
}

class _ClockInWidgetState extends State<ClockInWidget> {
  bool _isLoading = false;
  double _dragPosition = 0.0;
  bool _isSuccess = false;

  Future<void> _handleComplete() async {
    if (_isLoading || widget.onPressed == null) return;

    setState(() => _isLoading = true);

    try {
      await widget.onPressed!();
      if (mounted) {
        setState(() {
          _isSuccess = true;
        });
        AppFeedback.showSuccess(context, 'Attendance Logged Successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
           _dragPosition = 0.0;
        });
        AppFeedback.showError(context, 'Failed to log attendance. ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (_isLoading || _isSuccess || widget.onPressed == null) return;
    
    setState(() {
      _dragPosition += details.delta.dx;
      if (_dragPosition < 0) _dragPosition = 0;
      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
    });
    
    // Simulate mechanical ticking while dragging
    HapticFeedback.selectionClick();
  }

  void _onDragEnd(DragEndDetails details, double maxDrag) {
    if (_isLoading || _isSuccess || widget.onPressed == null) return;

    if (_dragPosition >= maxDrag * 0.85) {
      // Reached the end!
      setState(() => _dragPosition = maxDrag);
      HapticFeedback.heavyImpact();
      _handleComplete();
    } else {
      // Snap back
      setState(() => _dragPosition = 0.0);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Height of our container: padding (16*2) + icon height (48) = approx 80
        const double sliderHeight = 84.0;
        const double iconSize = 48.0;
        final double maxDrag = constraints.maxWidth - iconSize - 24; // 12 padding on edges

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: sliderHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDisabled 
                ? context.colors.surfaceContainerLow.withValues(alpha: 0.5)
                : context.colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: isDisabled
                ? Border.all(color: context.colors.outline.withValues(alpha: 0.2))
                : CivicHorizonTheme.ghostBorder(context),
            boxShadow: isDisabled ? [] : CivicHorizonTheme.ambientGlow(context),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Text
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Opacity(
                    opacity: isDisabled ? 0.3 : 1.0 - (_dragPosition / maxDrag),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.overline,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isDisabled ? context.colors.outline : colors.primary,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          'SLIDE TO ${widget.title.split(" ").take(2).join(" ")} >>',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDisabled 
                                ? context.colors.outline 
                                : (widget.isErrorStyle ? colors.error : colors.primary),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Sliding Knob
              AnimatedPositioned(
                duration: _dragPosition == 0 ? const Duration(milliseconds: 300) : Duration.zero,
                curve: Curves.easeOutBack,
                left: _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onDragUpdate(details, maxDrag),
                  onHorizontalDragEnd: (details) => _onDragEnd(details, maxDrag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: _isSuccess 
                          ? CivicHorizonTheme.tertiaryFixedDim 
                          : (_isLoading ? widget.iconBgColor.withAlpha(50) : widget.iconBgColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoading 
                      ? Center(
                          child: SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(
                              color: widget.iconBgColor, 
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : Icon(
                          _isSuccess ? Icons.check : Icons.double_arrow_rounded,
                          color: widget.iconColor,
                          size: 24,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
