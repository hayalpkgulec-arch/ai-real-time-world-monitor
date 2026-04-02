import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';

/// Intelligence feed item — timeline-style with dot indicator and animated AI badges.
class FeedItem extends StatefulWidget {
  final String id;
  final String timestamp;
  final String content;
  final List<String> tags;
  final FeedSeverity severity;
  final bool showConnector;
  // Source verification fields
  final String? sourceDomain;
  final String? ageDisplay;
  final String? verificationStatus;
  final bool isRealtime;
  final bool isFresh;
  // AI Analysis fields
  final String? aiVerificationTier;
  final String? aiSummary;
  final List<String>? aiRedFlags;
  final List<String>? aiTrustIndicators;

  const FeedItem({
    super.key,
    required this.id,
    required this.timestamp,
    required this.content,
    required this.tags,
    this.severity = FeedSeverity.normal,
    this.showConnector = true,
    this.sourceDomain,
    this.ageDisplay,
    this.verificationStatus,
    this.isRealtime = false,
    this.isFresh = false,
    // AI Analysis
    this.aiVerificationTier,
    this.aiSummary,
    this.aiRedFlags,
    this.aiTrustIndicators,
  });

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _checkAnalyzingState();
  }

  void _checkAnalyzingState() {
    bool _isAnalyzing = widget.aiVerificationTier == null;
    if (_isAnalyzing) {
      _shimmerController.repeat();
      _fadeController.value = 0;
    } else {
      _shimmerController.stop();
      _fadeController.value = 1;
    }
  }

  @override
  void didUpdateWidget(FeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if analyzing state changed
    final wasAnalyzing = oldWidget.aiVerificationTier == null;
    final isAnalyzing = widget.aiVerificationTier == null;
    
    if (wasAnalyzing && !isAnalyzing) {
      // Analysis completed - stop shimmer and fade in results
      _shimmerController.stop();
      _fadeController.forward(from: 0);
    } else if (!wasAnalyzing && isAnalyzing) {
      // Started analyzing - start shimmer
      _shimmerController.repeat();
      _fadeController.value = 0;
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool get _isAnalyzing => widget.aiVerificationTier == null;

  Color get _dotColor {
    switch (widget.severity) {
      case FeedSeverity.critical:
        return AegisColors.tertiary;
      case FeedSeverity.warning:
        return AegisColors.secondary;
      case FeedSeverity.normal:
        return widget.isRealtime ? Colors.green : AegisColors.onSurfaceVariant;
    }
  }

  Color? get _verificationBadgeColor {
    final tier = _getSimplifiedVerificationTier(widget.aiVerificationTier ?? widget.verificationStatus ?? 'UNVERIFIED');
    switch (tier) {
      case 'VERIFIED':
        return Colors.green.withOpacity(0.15);
      case 'SUSPICIOUS':
        return Colors.red.withOpacity(0.15);
      default:
        return null;
    }
  }

  Color? get _verificationTextColor {
    final tier = _getSimplifiedVerificationTier(widget.aiVerificationTier ?? widget.verificationStatus ?? 'UNVERIFIED');
    switch (tier) {
      case 'VERIFIED':
        return Colors.green;
      case 'SUSPICIOUS':
        return Colors.red;
      default:
        return AegisColors.outline;
    }
  }

  String get _displayVerificationStatus {
    return _getSimplifiedVerificationTier(widget.aiVerificationTier ?? widget.verificationStatus ?? 'UNVERIFIED');
  }

  /// Simplify verification tiers to only VERIFIED or SUSPICIOUS
  String _getSimplifiedVerificationTier(String tier) {
    switch (tier.toUpperCase()) {
      case 'VERIFIED':
      case 'FRESH':
      case 'LIKELY_TRUE':
        return 'VERIFIED';
      case 'SUSPICIOUS':
      case 'UNVERIFIED':
      case 'SINGLE_SOURCE':
      case 'STALE':
        return 'SUSPICIOUS';
      default:
        return 'SUSPICIOUS';
    }
  }

  Widget _buildShimmerBadge() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0,
              endAngle: 3.14159 * 2,
              transform: GradientRotation(_shimmerController.value * 3.14159 * 2),
              colors: [
                AegisColors.surfaceContainerHighest.withValues(alpha: 0.4),
                AegisColors.surfaceContainerHigh.withValues(alpha: 0.7),
                AegisColors.surfaceContainerHighest.withValues(alpha: 0.5),
                AegisColors.surfaceContainerHighest.withValues(alpha: 0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AegisColors.surfaceContainerHighest.withValues(alpha: 0.15 + (_shimmerController.value * 0.2)),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AegisColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'AI ANALYZING',
                style: AegisTypography.labelXs.copyWith(
                  color: AegisColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIBadges() {
    if (_isAnalyzing) {
      return _buildShimmerBadge();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Verification status badge only
          if (_displayVerificationStatus != 'UNVERIFIED') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _verificationBadgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _displayVerificationStatus.toUpperCase(),
                style: AegisTypography.labelXs.copyWith(
                  color: _verificationTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        SizedBox(
          width: 20,
          child: Column(
            children: [
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _dotColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              if (widget.showConnector)
                Container(
                  width: 1,
                  height: 60,
                  margin: const EdgeInsets.only(top: 8),
                  color: AegisColors.outlineVariant.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID + Timestamp + Source + AI Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // ID
                    Text(
                      widget.id.toUpperCase(),
                      style: AegisTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.0,
                      ),
                    ),
                    // Source domain badge
                    if (widget.sourceDomain != null)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AegisColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.sourceDomain!.toUpperCase(),
                          style: AegisTypography.labelXs.copyWith(
                            color: AegisColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    // AI Badges with shimmer/fade animation
                    _buildAIBadges(),
                    // Age display
                    if (widget.ageDisplay != null)
                      Text(
                        widget.ageDisplay!,
                        style: AegisTypography.labelXs.copyWith(
                          color: widget.isRealtime
                              ? Colors.green
                              : (widget.isFresh ? Colors.orange : AegisColors.outline),
                          fontWeight: widget.isRealtime || widget.isFresh
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Description
                Text(
                  widget.content,
                  style: AegisTypography.bodyMd.copyWith(
                    color: AegisColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AegisColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: AegisTypography.labelXs.copyWith(
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum FeedSeverity { critical, warning, normal }
