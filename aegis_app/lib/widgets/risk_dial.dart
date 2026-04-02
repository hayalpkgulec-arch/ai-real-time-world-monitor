import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';

/// Circular risk dial widget — the hero element from Home screen.
/// Shows risk score with animated arc and color-coded severity.
class RiskDial extends StatefulWidget {
  final double riskScore;
  final String riskLevel;
  final double size;

  const RiskDial({
    super.key,
    required this.riskScore,
    required this.riskLevel,
    this.size = 200,
  });

  @override
  State<RiskDial> createState() => _RiskDialState();
}

class _RiskDialState extends State<RiskDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.riskScore / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(RiskDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.riskScore != widget.riskScore) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.riskScore / 100,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _riskColor {
    if (widget.riskScore >= 80) return AegisColors.tertiaryFixed;
    if (widget.riskScore >= 60) return AegisColors.tertiary;
    if (widget.riskScore >= 40) return const Color(0xFFFFD600);
    if (widget.riskScore >= 20) return const Color(0xFF2979FF);
    return AegisColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _RiskDialPainter(
              progress: _animation.value,
              riskColor: _riskColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RISK LEVEL',
                    style: AegisTypography.labelSm.copyWith(
                      color: AegisColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.riskScore.toStringAsFixed(1),
                    style: AegisTypography.displayLg.copyWith(
                      fontSize: widget.size * 0.22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.riskLevel.toUpperCase(),
                    style: AegisTypography.labelSm.copyWith(
                      color: _riskColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RiskDialPainter extends CustomPainter {
  final double progress;
  final Color riskColor;

  _RiskDialPainter({required this.progress, required this.riskColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background arc
    final bgPaint = Paint()
      ..color = AegisColors.surfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75, // Start at top-left
      pi * 1.5,    // 270 degrees
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = riskColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      pi * 1.5 * progress,
      false,
      progressPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = riskColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      pi * 1.5 * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_RiskDialPainter oldDelegate) =>
      progress != oldDelegate.progress || riskColor != oldDelegate.riskColor;
}
