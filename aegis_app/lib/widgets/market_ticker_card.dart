import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';

/// Market ticker card with sparkline chart.
/// Displays asset name, price, change%, and mini chart.
class MarketTickerCard extends StatelessWidget {
  final String label;
  final String price;
  final String changePercent;
  final bool isPositive;
  final List<double> sparklineData;

  const MarketTickerCard({
    super.key,
    required this.label,
    required this.price,
    required this.changePercent,
    required this.isPositive,
    required this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isPositive ? AegisColors.secondary : AegisColors.tertiary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AegisTypography.labelSm.copyWith(
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price, style: AegisTypography.dataLg),
                    const SizedBox(width: 8),
                    Text(
                      changePercent,
                      style: AegisTypography.labelMd.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 36,
            child: CustomPaint(
              painter: _SparklinePainter(
                data: sparklineData,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;
    if (range == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      data != oldDelegate.data || color != oldDelegate.color;
}
