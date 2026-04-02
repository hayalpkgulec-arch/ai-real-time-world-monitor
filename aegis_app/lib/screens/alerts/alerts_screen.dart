import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';
import '../../widgets/alert_card.dart';

/// Alerts screen — Critical alerts with incident logs.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority header
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AegisColors.tertiaryFixed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SYSTEM PRIORITY: OMEGA',
                    style: AegisTypography.labelMd.copyWith(
                      color: AegisColors.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'CRITICAL\nALERTS',
                style: AegisTypography.headlineLg.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 16),
              // System stats
              Row(
                children: [
                  Expanded(
                    child: _systemStat('CORE INTEGRITY', '100%'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _systemStat('NETWORK UPTIME', '99.9%'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Alert cards
              const AlertCard(
                severityLabel: 'CRITICAL',
                severity: AlertSeverity.critical,
                timestamp: 'T-MINUS: 00:04:12',
                title:
                    'Cyber-Breach: Pacific Sector (Firewall L3)',
                description:
                    'Multiple unauthorized infiltration attempts detected at the Node-7 Central Hub. AI indicates a 94% probability of state-sponsored lateral movement. Defensive protocols are currently in phase 2 containment.',
                metadata: {
                  'Threat Origin': 'I14.23.109.82 [HIDDEN]',
                  'Affected Nodes': '14/256',
                },
                actionButtons: ['DECODE PACKETS'],
              ),
              const SizedBox(height: 12),
              AlertCard(
                severityLabel: 'ELEVATED',
                severity: AlertSeverity.elevated,
                timestamp: '14:22:09',
                title: 'Geo-STOL: Latency Spike',
                description:
                    'S-14 Satellite arrays reporting 400ms delay. Atmospheric interference suspected.',
                chart: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final heights = [30.0, 35.0, 25.0, 40.0, 50.0, 45.0, 38.0];
                      final isHigh = i >= 4;
                      return Container(
                        width: 28,
                        height: heights[i],
                        color: isHigh
                            ? AegisColors.tertiary.withValues(alpha: 0.7)
                            : AegisColors.tertiaryFixed,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const AlertCard(
                severityLabel: 'STABLE',
                severity: AlertSeverity.stable,
                timestamp: '12:05:41',
                title: 'Grid-Sync: Complete',
                description:
                    'Global power distribution monitoring successfully synchronized across all 12 zones.',
                metadata: {
                  'Verified: Protocol-Z': '✅',
                },
              ),
              const SizedBox(height: 24),
              // Live incident logs
              _buildIncidentLogs(),
            ],
          ),
        ),
        // Bottom action bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: AegisColors.background,
              border: Border(
                top: BorderSide(
                  color: AegisColors.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Active alerts count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ACTIVE\nALERTS',
                          style: AegisTypography.labelSm),
                      Text('1,248', style: AegisTypography.displaySm),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Silence All button
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AegisColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          'SILENCE ALL',
                          style: AegisTypography.labelSm.copyWith(
                            color: AegisColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Export button
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AegisColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'EXPORT LOGS',
                            style: AegisTypography.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _systemStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AegisTypography.labelSm),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              value,
              style: AegisTypography.dataMd.copyWith(
                color: AegisColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AegisColors.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value == '100%' ? 1.0 : 0.999,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AegisColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncidentLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE INCIDENT LOGS',
              style: AegisTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 3.0,
              ),
            ),
            // Pagination dots
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AegisColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AegisColors.onSurfaceVariant.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AegisColors.onSurfaceVariant.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _logRow('14:55:01', '[!]',
            'ENCRYPTION HANDSHAKE FAILED - NODE 009', 'TRACE:', '0.04s'),
        _logRow('14:54:32', '[↕]',
            'RE-ROUTING TRAFFIC THROUGH BACKUP CLUSTER 4', 'LOAD:', '12%'),
        _logRow('14:54:10', '[X]',
            'UNUSUAL PACKET SIZE DETECTED FROM IP: 44.12.9', 'SEC:', 'NULL'),
        _logRow('14:53:55', '[✓]',
            'DATABASE OPTIMIZATION AUTO-COMPLETED', 'ID:', '8872-A'),
      ],
    );
  }

  Widget _logRow(String time, String icon, String message,
      String metaKey, String metaValue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AegisColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: AegisTypography.labelSm.copyWith(
                color: AegisColors.outline,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              icon,
              style: AegisTypography.labelSm.copyWith(
                color: AegisColors.tertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              message,
              style: AegisTypography.bodySm.copyWith(
                color: AegisColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                metaKey,
                style: AegisTypography.labelXs.copyWith(
                  color: AegisColors.outline,
                ),
              ),
              Text(
                metaValue,
                style: AegisTypography.labelSm.copyWith(
                  color: AegisColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
