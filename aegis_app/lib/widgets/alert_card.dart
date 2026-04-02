import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';

/// Alert card for the Alerts screen.
/// Shows severity badge, title, description, metadata, and action buttons.
class AlertCard extends StatelessWidget {
  final String severityLabel;
  final AlertSeverity severity;
  final String timestamp;
  final String title;
  final String description;
  final Map<String, String>? metadata;
  final List<String>? actionButtons;
  final Widget? chart;

  const AlertCard({
    super.key,
    required this.severityLabel,
    required this.severity,
    required this.timestamp,
    required this.title,
    required this.description,
    this.metadata,
    this.actionButtons,
    this.chart,
  });

  Color get _severityBg {
    switch (severity) {
      case AlertSeverity.critical:
        return AegisColors.tertiaryContainer;
      case AlertSeverity.elevated:
        return const Color(0xFFFFD600);
      case AlertSeverity.stable:
        return AegisColors.secondaryContainer;
    }
  }

  Color get _severityTextColor {
    switch (severity) {
      case AlertSeverity.critical:
        return AegisColors.onTertiaryContainer;
      case AlertSeverity.elevated:
        return Colors.black;
      case AlertSeverity.stable:
        return AegisColors.onSecondaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: badge + timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _severityBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  severityLabel.toUpperCase(),
                  style: AegisTypography.labelSm.copyWith(
                    color: _severityTextColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                timestamp,
                style: AegisTypography.labelSm.copyWith(
                  color: AegisColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            title.toUpperCase(),
            style: AegisTypography.headlineMd.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            description,
            style: AegisTypography.bodyMd,
          ),
          // Optional chart
          if (chart != null) ...[
            const SizedBox(height: 16),
            chart!,
          ],
          // Metadata
          if (metadata != null && metadata!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: metadata!.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: AegisTypography.labelSm.copyWith(fontSize: 9),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.value,
                      style: AegisTypography.bodySm.copyWith(
                        color: AegisColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
          // Action buttons
          if (actionButtons != null && actionButtons!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: actionButtons!.map((label) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AegisColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: AegisTypography.labelSm.copyWith(
                      color: AegisColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

enum AlertSeverity { critical, elevated, stable }
