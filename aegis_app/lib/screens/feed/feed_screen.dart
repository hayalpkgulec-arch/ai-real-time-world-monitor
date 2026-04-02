import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/aegis_colors.dart';
import '../../core/theme/aegis_typography.dart';
import '../../core/services/feed_data_service.dart';
import '../../widgets/feed_item.dart';

/// Feed screen — full intelligence event feed with real-time updates.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedDataService _dataService = FeedDataService();
  List<FeedDataModel> _feedItems = [];
  Timer? _updateTimer;
  String _selectedFilter = 'ALL';
  bool _isLoading = true;
  bool _isRealTime = false;

  @override
  void initState() {
    super.initState();
    _initializeFeed();
  }

  Future<void> _initializeFeed() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load initial feed immediately without AI blocking
      final items = await _dataService.getInitialFeed();
      if (mounted) {
        setState(() {
          _feedItems = items;
          _isLoading = false;
          _isRealTime = _dataService.isRealTimeAvailable;
        });
      }
      _startRealTimeUpdates();
      
      /// Apply AI analysis in background and update items smoothly
      _applyBackgroundAIAnalysis(items);
    } catch (e) {
      debugPrint('Error initializing feed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _feedItems = _dataService.getFeedSync(); // Fallback to sync data
        });
      }
      _startRealTimeUpdates();
    }
  }

  /// Apply AI analysis in background and update items smoothly
  Future<void> _applyBackgroundAIAnalysis(List<FeedDataModel> items) async {
    for (int i = 0; i < items.length; i++) {
      if (!mounted) return;
      
      final analyzedItem = await _dataService.applyQuickAIAnalysis(items[i]);
      
      if (mounted) {
        setState(() {
          // Find and update specific item
          final index = _feedItems.indexWhere((item) => item.id == items[i].id);
          if (index != -1) {
            _feedItems[index] = analyzedItem;
          }
        });
      }
      
      // Small delay between analyses for smooth visual updates
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        final newItem = _dataService.generateNewFeedItem();
        
        // Insert immediately with analyzing state
        setState(() {
          _feedItems.insert(0, newItem);
          if (_feedItems.length > 20) {
            _feedItems.removeLast();
          }
        });
        
        // Enqueue for AI analysis with callback to update UI when complete
        _dataService.enqueueAIAnalysis(newItem, highPriority: true).then((analysis) {
          if (mounted) {
            setState(() {
              final index = _feedItems.indexWhere((item) => item.id == newItem.id);
              if (index != -1) {
                _feedItems[index] = FeedDataModel(
                  id: newItem.id,
                  timestamp: newItem.timestamp,
                  content: newItem.content,
                  tags: newItem.tags,
                  severity: analysis.verificationTier == 'SUSPICIOUS' ? 'warning' : newItem.severity,
                  sourceDomain: newItem.sourceDomain,
                  publishedAt: newItem.publishedAt,
                  url: newItem.url,
                  verificationStatus: analysis.verificationTier,
                  crossSources: newItem.crossSources,
                  aiVerificationTier: analysis.verificationTier,
                  aiSummary: analysis.aiSummary,
                  aiRedFlags: analysis.redFlags,
                  aiTrustIndicators: analysis.trustIndicators,
                );
              }
            });
          }
        }).catchError((error) {
          debugPrint('AI analysis failed for ${newItem.id}: $error');
        });
      }
    });
  }

  List<FeedDataModel> get _filteredItems {
    if (_selectedFilter == 'ALL') return _feedItems;
    return _feedItems.where((item) {
      if (_selectedFilter == 'CRITICAL') return item.severity == 'critical';
      if (_selectedFilter == 'CONFLICT') return item.tags.contains('CYBER') || item.tags.contains('DEFENSE');
      if (_selectedFilter == 'ECONOMIC') return item.tags.contains('ECON') || item.tags.contains('MARKET');
      if (_selectedFilter == 'CYBER') return item.tags.contains('CYBER');
      if (_selectedFilter == 'CLIMATE') return item.tags.contains('GEO');
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildFilterChips(),
          const SizedBox(height: 24),
          _buildStats(),
          const SizedBox(height: 24),
          ..._buildFeedItems(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'INTELLIGENCE\nFEED',
            style: AegisTypography.headlineLg.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _isRealTime 
                ? AegisColors.tertiary.withValues(alpha: 0.2)
                : AegisColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _isRealTime 
                      ? AegisColors.tertiaryFixed 
                      : AegisColors.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isRealTime ? 'LIVE API' : 'SIMULATION',
                style: AegisTypography.labelSm.copyWith(
                  color: _isRealTime ? AegisColors.tertiary : AegisColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip('ALL', _selectedFilter == 'ALL'),
          _filterChip('CRITICAL', _selectedFilter == 'CRITICAL'),
          _filterChip('CONFLICT', _selectedFilter == 'CONFLICT'),
          _filterChip('ECONOMIC', _selectedFilter == 'ECONOMIC'),
          _filterChip('CYBER', _selectedFilter == 'CYBER'),
          _filterChip('CLIMATE', _selectedFilter == 'CLIMATE'),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final criticalCount = _feedItems.where((i) => i.severity == 'critical').length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AegisColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('ACTIVE', _feedItems.length.toString()),
          _buildStat('CRITICAL', criticalCount.toString()),
          _buildStat('SOURCE', _isRealTime ? 'NEWS API' : 'SIM'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AegisTypography.dataMd),
        const SizedBox(height: 4),
        Text(label, style: AegisTypography.labelXs),
      ],
    );
  }

  List<Widget> _buildFeedItems() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No events match selected filter',
              style: AegisTypography.bodyMd,
            ),
          ),
        ),
      ];
    }

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return FeedItem(
        id: item.id,
        timestamp: item.timestamp,
        content: item.content,
        tags: item.tags,
        severity: _parseSeverity(item.severity),
        showConnector: index < items.length - 1,
        // Source verification fields
        sourceDomain: item.sourceDomain,
        ageDisplay: item.ageDisplay,
        verificationStatus: item.verificationStatus,
        isRealtime: item.isRealtime,
        isFresh: item.isFresh,
        // AI Analysis fields
        aiVerificationTier: item.aiVerificationTier,
        aiSummary: item.aiSummary,
        aiRedFlags: item.aiRedFlags,
        aiTrustIndicators: item.aiTrustIndicators,
      );
    }).toList();
  }

  FeedSeverity _parseSeverity(String severity) {
    switch (severity) {
      case 'critical':
        return FeedSeverity.critical;
      case 'warning':
        return FeedSeverity.warning;
      default:
        return FeedSeverity.normal;
    }
  }

  Widget _filterChip(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AegisColors.primary.withValues(alpha: 0.15)
              : AegisColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
          border: isActive
              ? Border.all(color: AegisColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          label,
          style: AegisTypography.labelSm.copyWith(
            color: isActive ? AegisColors.primary : AegisColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
