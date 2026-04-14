import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/civic_horizon_theme.dart';

class ProgressRingWidget extends StatefulWidget {
  final double accumulatedHours;
  final double targetHours;
  final double dailyShiftHours;

  const ProgressRingWidget({
    super.key,
    required this.accumulatedHours,
    required this.targetHours,
    this.dailyShiftHours = 8.0,
  });

  @override
  State<ProgressRingWidget> createState() => _ProgressRingWidgetState();
}

class _ProgressRingWidgetState extends State<ProgressRingWidget> {
  bool _isFlipped = false;

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final percentage = widget.targetHours > 0 
        ? (widget.accumulatedHours / widget.targetHours).clamp(0.0, 1.0) 
        : 0.0;
        
    final remainingHours = (widget.targetHours - widget.accumulatedHours).clamp(0.0, widget.targetHours);
    final estimatedShifts = widget.dailyShiftHours > 0 
        ? (remainingHours / widget.dailyShiftHours).ceil() 
        : 0;

    return GestureDetector(
      onTap: _flipCard,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnim,
            child: child,
            builder: (context, widget) {
              final isUnder = (ValueKey(_isFlipped) != widget?.key);
              final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateY(value),
                alignment: Alignment.center,
                child: widget,
              );
            },
          );
        },
        child: _isFlipped 
            ? _buildStatsCard(context, remainingHours, estimatedShifts, percentage)
            : _buildRing(context, percentage, colors),
      ),
    );
  }

  Widget _buildRing(BuildContext context, double percentage, ColorScheme colors) {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: CivicHorizonTheme.ghostBorder(context),
        boxShadow: CivicHorizonTheme.ambientGlow(context),
      ),
      child: Column(
        children: [
          Text(
            'INTERNSHIP JOURNEY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: context.colors.outline,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: percentage),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: value,
                    trackColor: context.colors.outline.withValues(alpha: 0.1),
                    progressColor: colors.primary,
                    strokeWidth: 16.0,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.accumulatedHours.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          '/ ${widget.targetHours.toInt()} HRS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurfaceVariant,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Tap for details',
            style: TextStyle(
              fontSize: 10,
              color: context.colors.outline.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, double remainingHours, int estimatedShifts, double percentage) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      // Match approximate height of the ring for exact bounds flipping
      height: 280, 
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'MILESTONE ANALYTICS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: colors.onPrimary.withValues(alpha: 0.7),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          _statRow('Completion Rate', '${(percentage * 100).toStringAsFixed(1)}%', colors.onPrimary),
          const SizedBox(height: 16),
          _statRow('Hours Remaining', '${remainingHours.toStringAsFixed(1)} hrs', colors.onPrimary),
          const SizedBox(height: 16),
          _statRow('Est. Shifts Left', '$estimatedShifts days', colors.onPrimary),
          const SizedBox(height: 16),
          _statRow('Required Daily Average', '${widget.dailyShiftHours.toStringAsFixed(1)} hrs/day', colors.onPrimary),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw the ghosted background track
    canvas.drawCircle(center, radius, trackPaint);

    // Draw the foreground progress arc
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start at exactly 12 o'clock
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
