import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';
import '../../widgets/risk_dial.dart';
import '../../widgets/market_ticker_card.dart';
import '../../widgets/operation_card.dart';
import '../../widgets/feed_item.dart';

/// Home Dashboard — the main screen of AEGIS Intelligence.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Risk Dial + Summary ──
          _buildRiskHero(),
          const SizedBox(height: 16),
          // ── Market Tickers ──
          _buildMarketTickers(),
          const SizedBox(height: 28),
          // ── Active Operations ──
          _buildActiveOps(),
          const SizedBox(height: 28),
          // ── Global Coverage Map Preview ──
          _buildMapPreview(context),
          const SizedBox(height: 28),
          // ── Intelligence Feed ──
          _buildIntelFeed(),
        ],
      ),
    );
  }

  Widget _buildRiskHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const RiskDial(
            riskScore: 74.8,
            riskLevel: 'ELEVATED',
            size: 200,
          ),
          const SizedBox(height: 24),
          // Status indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AegisColors.tertiaryFixed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AegisColors.tertiaryFixed.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'SYSTEM STATUS: ACTIVE MONITORING',
                  style: AegisTypography.labelSm,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Global Volatility\nSummary',
            textAlign: TextAlign.center,
            style: AegisTypography.headlineLg.copyWith(
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Heightened activity detected in maritime logistics corridors. Sentiment analysis of diplomatic cables indicates a 12% increase in regional tension over the last 24H period. All nodes report high fidelity.',
            textAlign: TextAlign.center,
            style: AegisTypography.bodyMd,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          // Stats row
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth - 16) / 3,
                    child: _buildStat('CONFIDENCE', '98.2%'),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 16) / 3,
                    child: _buildStat('ACTIVE NODES', '14,209'),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 16) / 3,
                    child: _buildStat('THROUGHPUT', '4.2 PB/s'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AegisTypography.labelSm),
          const SizedBox(height: 4),
          Text(value, style: AegisTypography.dataMd),
        ],
      ),
    );
  }

  Widget _buildMarketTickers() {
    return Column(
      children: const [
        MarketTickerCard(
          label: 'WTI Crude Oil',
          price: '82.44',
          changePercent: '+1.24%',
          isPositive: true,
          sparklineData: [35, 32, 34, 28, 30, 20, 22, 15, 18, 10, 5],
        ),
        SizedBox(height: 8),
        MarketTickerCard(
          label: 'Gold Spot',
          price: '2341.10',
          changePercent: '-0.42%',
          isPositive: false,
          sparklineData: [5, 12, 10, 18, 15, 25, 22, 30, 28, 35, 32],
        ),
        SizedBox(height: 8),
        MarketTickerCard(
          label: 'Bitcoin (BTC)',
          price: '64,921',
          changePercent: '+4.88%',
          isPositive: true,
          sparklineData: [38, 30, 35, 20, 25, 10, 15, 5, 12, 2, 0],
        ),
      ],
    );
  }

  Widget _buildActiveOps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hub, color: AegisColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AEGIS CORE ACTIVE OPS',
                        style: AegisTypography.headlineSm.copyWith(
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Text(
                  'SECURE_CHANNEL: 4.492-X',
                  style: AegisTypography.labelSm,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        const OperationCard(
          icon: Icons.satellite_alt,
          title: 'Project Silver-Point',
          description:
              'Real-time surveillance monitoring of contested orbital slots. High fidelity data streams active from...',
          statusLabel: 'STABLE',
          isCritical: false,
          metaLabel: 'Target: LEO-4421',
        ),
        const SizedBox(height: 8),
        const OperationCard(
          icon: Icons.security,
          title: 'Op: Crimson Shield',
          description:
              'Cyber-resilience audit of critical energy infrastructure across the Northern Hemisphere....',
          statusLabel: 'ONGOING',
          isCritical: true,
          metaLabel: 'Vector: GRID-X',
        ),
      ],
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // Map placeholder with gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AegisColors.surfaceContainerHigh.withValues(alpha: 0.6),
                  AegisColors.surfaceContainerLow,
                ],
              ),
            ),
            child: CustomPaint(
              painter: _SimpleGlobePainter(),
              size: const Size(double.infinity, 180),
            ),
          ),
          // Content overlay
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AegisColors.surfaceContainerHighest
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.public,
                        color: AegisColors.onSurface,
                        size: 20,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'GLOBAL COVERAGE',
                          style: AegisTypography.labelSm,
                        ),
                        Text('94.8%', style: AegisTypography.dataLg),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AegisColors.surfaceContainerHighest
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monitoring all 18 sectors.',
                        style: AegisTypography.labelSm,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        color: AegisColors.primary,
                        child: Text(
                          'OPEN MAP',
                          style: AegisTypography.labelSm.copyWith(
                            color: AegisColors.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelFeed() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.rss_feed,
                      color: AegisColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'INTELLIGENCE FEED',
                    style: AegisTypography.headlineSm.copyWith(fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AegisColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LIVE UPDATES',
                  style: AegisTypography.labelSm.copyWith(
                    color: AegisColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Feed items
          const FeedItem(
            id: 'TS-ID // 8829-X',
            timestamp: '12:04:22',
            content: 'Anomalous frequency spike detected in Arctic Sector 4.',
            tags: ['SIGINT', 'NORAD'],
            severity: FeedSeverity.warning,
          ),
          const FeedItem(
            id: 'DB-ID // 4011-P',
            timestamp: '11:58:04',
            content:
                'Market volatility alert: Crude Oil futures surge 1.2% in 4 mins.',
            tags: ['ECON', 'CRITICAL'],
            severity: FeedSeverity.critical,
          ),
          const FeedItem(
            id: 'OP-ID // 9920-W',
            timestamp: '11:42:15',
            content:
                'Constellation SIGMA repositioning complete. 100% throughput.',
            tags: ['SYSTEM', 'AUTO'],
            severity: FeedSeverity.normal,
            showConnector: false,
          ),
          // Download button
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AegisColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'DOWNLOAD FULL LOG ARCHIVE (.RAW)',
                  style: AegisTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple globe/map background painter for the map preview card.
class _SimpleGlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AegisColors.surfaceContainerHigh.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw simple grid lines to represent globe
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Hotspot dots
    final dotPaint = Paint()
      ..color = AegisColors.tertiaryFixed
      ..style = PaintingStyle.fill;
    
    final glowPaint = Paint()
      ..color = AegisColors.tertiaryFixed.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Middle East area
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.35), 8, glowPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.35), 4, dotPaint);
    
    // South America area
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 6, glowPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
