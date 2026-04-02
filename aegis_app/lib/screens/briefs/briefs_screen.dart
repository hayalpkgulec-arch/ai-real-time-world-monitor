import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';

/// Briefs screen — Daily Global Report.
class BriefsScreen extends StatelessWidget {
  const BriefsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live status
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AegisColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AegisColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE FEED ACTIVE',
                      style: AegisTypography.labelSm.copyWith(
                        color: AegisColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'TS-ID // 8920-X-DELTA',
                style: AegisTypography.labelSm,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'DAILY\nGLOBAL\nREPORT',
            style: AegisTypography.headlineLg.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'THURSDAY // OCTOBER 24, 2024 //\n08:00 UTC',
            style: AegisTypography.labelMd,
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AegisColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share,
                          color: AegisColors.onSurface, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'SHARE',
                        style: AegisTypography.labelSm.copyWith(
                          color: AegisColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AegisColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download,
                          color: AegisColors.onSurface, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'EXPORT PDF',
                        style: AegisTypography.labelSm.copyWith(
                          color: AegisColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats
          _buildStatCard('EVENTS (24H)', '1,482', true),
          const SizedBox(height: 8),
          _buildRiskStatusCard(),
          const SizedBox(height: 8),
          _buildThreatChart(),
          const SizedBox(height: 24),
          // Intelligence sections
          _buildIntelSection(
            secId: 'SEC-01 // GEO-POLITICAL',
            title: 'CENTRAL EUROPEAN ENERGY CORRIDOR INSTABILITY',
            description:
                'Unscheduled maintenance alerts across three major nodes have triggered a 14% volatility spike in regional futures. AI analysis suggests 62% probability of coordinated kinetic disruption.',
            impactLabel: 'Impact Vector',
            impactValue: 'Systems Tier-2\nVulnerability identified in\ngrid redundancy.',
            marketLabel: 'Market Signal',
            marketValue: '⚡ HIGH VOLATILITY',
          ),
          const SizedBox(height: 16),
          _buildIntelSection(
            secId: 'SEC-02 // CYBER-INTEL',
            title: 'QUANTUM-RESISTANT LAYER 1 BREACH DETECTED',
            description:
                'Sentinel-X detected a brute-force pattern targeting secure financial ledger protocols. Forensic footprint matches advanced state-sponsored actor "GHOST-7".',
            impactLabel: 'Security Status',
            impactValue: 'Node integrity nominal.\nPatch RL_4.2 deployment\nactive.',
            marketLabel: 'Asset Impact',
            marketValue: '✅ STABLE OUTLOOK',
          ),
          const SizedBox(height: 24),
          // Chief Analyst Conclusion
          _buildAnalystConclusion(),
          const SizedBox(height: 24),
          // Signal confidence
          _buildSignalConfidence(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, bool hasChart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AegisTypography.labelSm),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: AegisTypography.displaySm),
                  if (hasChart) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.trending_up,
                        color: AegisColors.tertiary, size: 20),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RISK STATUS', style: AegisTypography.labelSm),
              const SizedBox(height: 4),
              Text(
                'ELEVATED',
                style: AegisTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AegisColors.secondary, AegisColors.tertiaryFixed],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreatChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THREAT PROPAGATION TREND 7-DAY ANALYSIS',
                style: AegisTypography.labelSm.copyWith(fontSize: 8),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AegisColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CRITICAL // ALPHA',
                  style: AegisTypography.labelXs.copyWith(
                    color: AegisColors.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: _ThreatChartPainter(),
              size: const Size(double.infinity, 60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelSection({
    required String secId,
    required String title,
    required String description,
    required String impactLabel,
    required String impactValue,
    required String marketLabel,
    required String marketValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(secId, style: AegisTypography.labelSm),
          const SizedBox(height: 12),
          Text(
            title,
            style: AegisTypography.headlineMd.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(description, style: AegisTypography.bodyMd),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      impactLabel.toUpperCase(),
                      style: AegisTypography.labelSm.copyWith(fontSize: 9),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      impactValue,
                      style: AegisTypography.bodySm.copyWith(
                        color: AegisColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marketLabel.toUpperCase(),
                      style: AegisTypography.labelSm.copyWith(fontSize: 9),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      marketValue,
                      style: AegisTypography.bodySm.copyWith(
                        color: AegisColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalystConclusion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHIEF ANALYST CONCLUSION',
            style: AegisTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AegisColors.onSurface,
                height: 1.4,
              ),
              children: const [
                TextSpan(
                  text:
                      'The current global posture is characterized by high cyber-sensitivity and shifting energy dependencies. While trade logistics show signs of stabilization, the energy corridor remains a ',
                ),
                TextSpan(
                  text: 'critical point of failure',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(text: ' for the next 72 hours.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalConfidence() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text('SIGNAL CONFIDENCE', style: AegisTypography.labelSm),
          const SizedBox(height: 8),
          Text(
            '94.8%',
            style: AegisTypography.displayMd.copyWith(
              color: AegisColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text('VERIFIED DIGITAL IDENTITY', style: AegisTypography.labelSm),
          const SizedBox(height: 4),
          Text(
            'K. Sterling Vault',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: AegisColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified,
                  color: AegisColors.secondary, size: 14),
              const SizedBox(width: 4),
              Text(
                'IDENTITY CONFIRMED',
                style: AegisTypography.labelSm.copyWith(
                  color: AegisColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThreatChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid
    final gridPaint = Paint()
      ..color = AegisColors.outlineVariant.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Red threat line
    final threatPaint = Paint()
      ..color = AegisColors.tertiaryFixed
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(
        size.width * 0.2, size.height * 0.5,
        size.width * 0.4, size.height * 0.8,
        size.width * 0.5, size.height * 0.4,
      )
      ..cubicTo(
        size.width * 0.6, size.height * 0.1,
        size.width * 0.8, size.height * 0.3,
        size.width, size.height * 0.2,
      );
    canvas.drawPath(path, threatPaint);

    // Green baseline
    final basePaint = Paint()
      ..color = AegisColors.secondary.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final basePath = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(
        size.width * 0.3, size.height * 0.75,
        size.width * 0.6, size.height * 0.7,
        size.width, size.height * 0.65,
      );
    canvas.drawPath(basePath, basePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
