import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';

/// Operation card for the AEGIS CORE ACTIVE OPS section.
class OperationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String statusLabel;
  final bool isCritical;
  final String metaLabel;
  final VoidCallback? onTap;

  const OperationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.statusLabel,
    this.isCritical = false,
    required this.metaLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusBg = isCritical
        ? AegisColors.tertiaryContainer
        : AegisColors.secondaryContainer;
    final statusText = isCritical
        ? AegisColors.onTertiaryContainer
        : AegisColors.onSecondaryContainer;
    final iconBg = isCritical
        ? AegisColors.tertiary.withValues(alpha: 0.1)
        : AegisColors.primary.withValues(alpha: 0.1);
    final iconColor = isCritical ? AegisColors.tertiary : AegisColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AegisColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: AegisTypography.labelSm.copyWith(
                      color: statusText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              title,
              style: AegisTypography.headlineSm.copyWith(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              description,
              style: AegisTypography.bodySm,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Footer: meta + access button
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AegisColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      metaLabel.toUpperCase(),
                      style: AegisTypography.labelSm,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ACCESS',
                        style: AegisTypography.labelSm.copyWith(
                          color: AegisColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AegisColors.primary,
                      ),
                    ],
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
