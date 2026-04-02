import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';

/// Map screen — dark monochromatic world map with risk hotspots.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map area (full screen)
        Positioned.fill(
          child: Container(
            color: AegisColors.surface,
            child: CustomPaint(
              painter: _WorldMapPainter(),
            ),
          ),
        ),

        // Search bar
        Positioned(
          top: 8,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AegisColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.search,
                    color: AegisColors.onSurfaceVariant, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LOCATE REGION OR EVENT',
                    style: AegisTypography.labelMd.copyWith(
                      color: AegisColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: AegisColors.outlineVariant,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.tune,
                    color: AegisColors.onSurfaceVariant, size: 20),
              ],
            ),
          ),
        ),

        // Map controls (right side)
        Positioned(
          right: 16,
          bottom: 180,
          child: Column(
            children: [
              _mapControlButton(Icons.add),
              const SizedBox(height: 8),
              _mapControlButton(Icons.remove),
              const SizedBox(height: 8),
              _mapControlButton(Icons.layers_outlined),
              const SizedBox(height: 8),
              _mapControlButton(Icons.my_location),
            ],
          ),
        ),

        // Legend panel
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AegisColors.surfaceContainerLow.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MAP INTELLIGENCE LEGEND',
                  style: AegisTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 16),
                _legendItem(AegisColors.tertiaryFixed, 'CONFLICT'),
                const SizedBox(height: 10),
                _legendItem(AegisColors.tertiary, 'ECONOMIC RISK'),
                const SizedBox(height: 10),
                _legendItem(AegisColors.secondary, 'NATURAL/STABLE'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapControlButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: AegisColors.onSurface, size: 20),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AegisTypography.labelMd.copyWith(
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

/// Simplified world map painter with dark aesthetic.
class _WorldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = AegisColors.surface;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final landPaint = Paint()
      ..color = AegisColors.surfaceContainerHigh
      ..style = PaintingStyle.fill;

    // Simplified continent shapes
    // North America
    final na = Path()
      ..moveTo(size.width * 0.08, size.height * 0.15)
      ..lineTo(size.width * 0.28, size.height * 0.12)
      ..lineTo(size.width * 0.30, size.height * 0.30)
      ..lineTo(size.width * 0.22, size.height * 0.45)
      ..lineTo(size.width * 0.15, size.height * 0.48)
      ..lineTo(size.width * 0.10, size.height * 0.35)
      ..close();
    canvas.drawPath(na, landPaint);

    // South America
    final sa = Path()
      ..moveTo(size.width * 0.20, size.height * 0.52)
      ..lineTo(size.width * 0.28, size.height * 0.50)
      ..lineTo(size.width * 0.30, size.height * 0.65)
      ..lineTo(size.width * 0.25, size.height * 0.85)
      ..lineTo(size.width * 0.20, size.height * 0.80)
      ..lineTo(size.width * 0.18, size.height * 0.60)
      ..close();
    canvas.drawPath(sa, landPaint);

    // Europe
    final eu = Path()
      ..moveTo(size.width * 0.42, size.height * 0.12)
      ..lineTo(size.width * 0.55, size.height * 0.10)
      ..lineTo(size.width * 0.56, size.height * 0.30)
      ..lineTo(size.width * 0.48, size.height * 0.35)
      ..lineTo(size.width * 0.42, size.height * 0.28)
      ..close();
    canvas.drawPath(eu, landPaint);

    // Africa
    final af = Path()
      ..moveTo(size.width * 0.42, size.height * 0.38)
      ..lineTo(size.width * 0.56, size.height * 0.36)
      ..lineTo(size.width * 0.58, size.height * 0.60)
      ..lineTo(size.width * 0.52, size.height * 0.78)
      ..lineTo(size.width * 0.44, size.height * 0.70)
      ..lineTo(size.width * 0.42, size.height * 0.50)
      ..close();
    canvas.drawPath(af, landPaint);

    // Asia
    final asia = Path()
      ..moveTo(size.width * 0.56, size.height * 0.08)
      ..lineTo(size.width * 0.88, size.height * 0.10)
      ..lineTo(size.width * 0.90, size.height * 0.40)
      ..lineTo(size.width * 0.75, size.height * 0.50)
      ..lineTo(size.width * 0.60, size.height * 0.45)
      ..lineTo(size.width * 0.56, size.height * 0.30)
      ..close();
    canvas.drawPath(asia, landPaint);

    // Australia
    final auz = Path()
      ..moveTo(size.width * 0.78, size.height * 0.62)
      ..lineTo(size.width * 0.92, size.height * 0.60)
      ..lineTo(size.width * 0.93, size.height * 0.78)
      ..lineTo(size.width * 0.80, size.height * 0.80)
      ..close();
    canvas.drawPath(auz, landPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = AegisColors.outlineVariant.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += size.width / 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += size.height / 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Conflict hotspots
    _drawHotspot(canvas, Offset(size.width * 0.55, size.height * 0.32),
        AegisColors.tertiaryFixed);
    _drawHotspot(canvas, Offset(size.width * 0.25, size.height * 0.55),
        AegisColors.tertiary);
  }

  void _drawHotspot(Canvas canvas, Offset center, Color color) {
    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, 18, glowPaint);

    // Core
    final corePaint = Paint()..color = color;
    canvas.drawCircle(center, 6, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
