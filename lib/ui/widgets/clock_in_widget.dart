import 'package:flutter/material.dart';
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

  Future<void> _handlePress() async {
    if (_isLoading || widget.onPressed == null) return;

    AppFeedback.lightClick();
    setState(() => _isLoading = true);

    try {
      await widget.onPressed!();
      if (mounted) {
        AppFeedback.showSuccess(context, 'Attendance Logged Successfully');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Failed to verify location. ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: (_isLoading || widget.onPressed == null) ? null : _handlePress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: widget.onPressed == null 
              ? context.colors.surfaceContainerLow.withValues(alpha: 0.5)
              : context.colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: widget.onPressed == null
              ? Border.all(color: context.colors.outline.withValues(alpha: 0.2))
              : CivicHorizonTheme.ghostBorder(context),
          boxShadow: widget.onPressed == null ? [] : CivicHorizonTheme.ambientGlow(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.overline,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: widget.onPressed == null 
                          ? context.colors.outline 
                          : colors.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: widget.onPressed == null
                          ? context.colors.outline
                          : (widget.isErrorStyle ? colors.error : colors.primary),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLoading ? widget.iconBgColor.withAlpha(20) : widget.iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoading 
                ? SizedBox(
                    width: 32, 
                    height: 32, 
                    child: CircularProgressIndicator(
                      color: widget.iconBgColor, 
                      strokeWidth: 3,
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 32,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
