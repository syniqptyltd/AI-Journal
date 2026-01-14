import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/breathing_exercise.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated breathing circle visualization
class BreathingAnimation extends StatefulWidget {
  final BreathPhase phase;
  final double progress; // 0.0 to 1.0
  final int secondsRemaining;
  final bool isActive;

  const BreathingAnimation({
    super.key,
    required this.phase,
    required this.progress,
    required this.secondsRemaining,
    this.isActive = true,
  });

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BreathingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _phaseColor {
    switch (widget.phase) {
      case BreathPhase.inhale:
        return AppColors.breatheIn;
      case BreathPhase.holdAfterInhale:
      case BreathPhase.holdAfterExhale:
        return AppColors.breatheHold;
      case BreathPhase.exhale:
        return AppColors.breatheOut;
    }
  }

  double get _targetScale {
    switch (widget.phase) {
      case BreathPhase.inhale:
        return 0.6 + (widget.progress * 0.4); // Grow from 0.6 to 1.0
      case BreathPhase.holdAfterInhale:
        return 1.0; // Stay large
      case BreathPhase.exhale:
        return 1.0 - (widget.progress * 0.4); // Shrink from 1.0 to 0.6
      case BreathPhase.holdAfterExhale:
        return 0.6; // Stay small
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = _pulseController.value * 0.03;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _phaseColor.withOpacity(0.1),
                      _phaseColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              // Main breathing circle
              AnimatedScale(
                scale: _targetScale + pulseValue,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _phaseColor.withOpacity(0.8),
                        _phaseColor.withOpacity(0.4),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _phaseColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.phase.instruction,
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.secondsRemaining}',
                    style: AppTypography.displayLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 48,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Progress ring around the breathing circle
class BreathingProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int currentCycle;
  final int totalCycles;

  const BreathingProgressRing({
    super.key,
    required this.progress,
    required this.currentCycle,
    required this.totalCycles,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          progress: progress,
          color: AppColors.primary,
          backgroundColor: AppColors.cardBorder,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 220),
              Text(
                'Cycle $currentCycle of $totalCycles',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 4.0;

    // Background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
