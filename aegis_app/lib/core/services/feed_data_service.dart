import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'real_time_feed_service.dart';
import 'ai_analysis_service.dart';

/// Data model for intelligence feed items
class FeedDataModel {
  final String id;
  final String timestamp;
  final String content;
  final List<String> tags;
  final String severity;
  // Source verification fields
  final String? sourceDomain; // e.g., "reuters.com", "bloomberg.com"
  final DateTime? publishedAt; // Original publish time from API
  final String? url; // Original article URL
  final String verificationStatus; // "VERIFIED", "SINGLE_SOURCE", "UNVERIFIED"
  final List<String>? crossSources; // Additional sources for same event
  // AI Analysis fields
  final String? aiVerificationTier; // VERIFIED, SUSPICIOUS
  final String? aiSummary;
  final List<String>? aiRedFlags;
  final List<String>? aiTrustIndicators;

  FeedDataModel({
    required this.id,
    required this.timestamp,
    required this.content,
    required this.tags,
    required this.severity,
    this.sourceDomain,
    this.publishedAt,
    this.url,
    this.verificationStatus = "UNVERIFIED",
    this.crossSources,
    // AI Analysis
    this.aiVerificationTier,
    this.aiSummary,
    this.aiRedFlags,
    this.aiTrustIndicators,
  });

  factory FeedDataModel.fromJson(Map<String, dynamic> json) {
    return FeedDataModel(
      id: json['id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      content: json['content'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      severity: json['severity'] ?? 'normal',
      sourceDomain: json['sourceDomain'],
      publishedAt: json['publishedAt'] != null ? DateTime.tryParse(json['publishedAt']) : null,
      url: json['url'],
      verificationStatus: json['verificationStatus'] ?? 'UNVERIFIED',
      crossSources: json['crossSources'] != null ? List<String>.from(json['crossSources']) : null,
      aiVerificationTier: json['aiVerificationTier'],
      aiSummary: json['aiSummary'],
      aiRedFlags: json['aiRedFlags'] != null ? List<String>.from(json['aiRedFlags']) : null,
      aiTrustIndicators: json['aiTrustIndicators'] != null ? List<String>.from(json['aiTrustIndicators']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'content': content,
      'tags': tags,
      'severity': severity,
      'sourceDomain': sourceDomain,
      'publishedAt': publishedAt?.toIso8601String(),
      'url': url,
      'verificationStatus': verificationStatus,
      'crossSources': crossSources,
      'aiVerificationTier': aiVerificationTier,
      'aiSummary': aiSummary,
      'aiRedFlags': aiRedFlags,
      'aiTrustIndicators': aiTrustIndicators,
    };
  }

  /// Calculate age of news in minutes
  int? get ageInMinutes {
    if (publishedAt == null) return null;
    return DateTime.now().difference(publishedAt!).inMinutes;
  }

  /// Get human-readable age string
  String get ageDisplay {
    final age = ageInMinutes;
    if (age == null) return "Unknown";
    if (age < 10) return "⚡ $age min ago";
    if (age < 60) return "🕐 $age min ago";
    if (age < 720) return "⏱️ ${age ~/ 60} hours ago";
    return "📅 ${age ~/ 1440} days ago";
  }

  /// Check if news is fresh (< 1 hour)
  bool get isFresh {
    final age = ageInMinutes;
    return age != null && age < 60;
  }

  /// Check if news is real-time (< 10 minutes)
  bool get isRealtime {
    final age = ageInMinutes;
    return age != null && age < 10;
  }
}

/// Service to provide real-time intelligence feed data
/// Uses actual NewsAPI when configured, falls back to simulation data otherwise
class FeedDataService {
  static final FeedDataService _instance = FeedDataService._internal();
  factory FeedDataService() => _instance;
  FeedDataService._internal() {
    _realTimeService.initialize();
  }

  final RealTimeFeedService _realTimeService = RealTimeFeedService();
  final AIAnalysisService _aiService = AIAnalysisService();
  
  List<FeedDataModel>? _cachedNewsData;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  // Fallback simulation data (used when API is not available)
  final List<String> _severities = ['critical', 'warning', 'normal'];
  final List<String> _tags = ['SIGINT', 'NORAD', 'ECON', 'CRITICAL', 'SYSTEM', 'AUTO', 'DIPLO', 'G7', 'CYBER', 'DEFENSE', 'MARKET', 'ANOMALY', 'GEO', 'POLITICAL', 'NEWS'];
  final List<String> _contents = [
    'Breaking: Cyber attack detected on major financial infrastructure.',
    'Market Alert: Oil prices surge 3% following geopolitical tensions.',
    'Intelligence Update: Satellite imagery shows increased military activity in contested region.',
    'Security Alert: Critical vulnerability discovered in widely-used encryption protocol.',
    'Economic Update: Central bank announces emergency measures to stabilize currency.',
    'Threat Assessment: New malware strain targeting critical infrastructure detected.',
    'Diplomatic: High-level talks between major powers suspended indefinitely.',
    'Climate Alert: Extreme weather event causing supply chain disruptions across continent.',
    'Tech Update: AI-powered surveillance system deployed at border checkpoints.',
    'Conflict Zone: Civilian casualties reported in latest escalation of regional conflict.',
    'Financial: Major cryptocurrency exchange reports suspicious outflows.',
    'Defense: Joint military exercise begins in strategic waterway.',
    'Intelligence: Communication intercepts suggest coordinated multi-nation operation.',
  ];

  int _feedCounter = 0;

  /// Get initial feed data (tries real API first, falls back to simulation)
  Future<List<FeedDataModel>> getInitialFeed() async {
    // Try to fetch real news data
    if (_realTimeService.isConfigured) {
      try {
        final realNews = await _realTimeService.fetchIntelligenceNews();
        _cachedNewsData = realNews;
        _lastFetchTime = DateTime.now();
        return realNews; // Return immediately, apply AI analysis in background
      } catch (e) {
        // Fall back to cached data if available
        if (_cachedNewsData != null && _cachedNewsData!.isNotEmpty) {
          return _cachedNewsData!;
        }
        // Fall back to simulation data
        return _getSimulationFeed();
      }
    }
    
    // No API configured, use simulation
    return _getSimulationFeed();
  }

  /// Get cached or simulation feed immediately (for UI initialization)
  List<FeedDataModel> getFeedSync() {
    // Return cached news if available
    if (_cachedNewsData != null && _cachedNewsData!.isNotEmpty) {
      return _cachedNewsData!;
    }
    // Return simulation data
    return _getSimulationFeed();
  }

  /// Get fresh news data (bypass cache)
  Future<List<FeedDataModel>> refreshFeed() async {
    if (_realTimeService.isConfigured) {
      try {
        final realNews = await _realTimeService.fetchIntelligenceNews();
        _cachedNewsData = realNews;
        _lastFetchTime = DateTime.now();
        // Apply AI analysis to all refreshed items
        return await applyAIAnalysis(realNews);
      } catch (e) {
        // Return cached or simulation with analysis
        final data = _cachedNewsData ?? _getSimulationFeed();
        return await applyAIAnalysis(data);
      }
    }
    final simulationData = _getSimulationFeed();
    return await applyAIAnalysis(simulationData);
  }

  List<FeedDataModel> _getSimulationFeed() {
    return [
      FeedDataModel(
        id: 'TS-ID // 8829-X',
        timestamp: _getCurrentTimestamp(),
        content: 'Anomalous frequency spike detected in Arctic Sector 4.',
        tags: ['SIGINT', 'NORAD'],
        severity: 'warning',
      ),
      FeedDataModel(
        id: 'DB-ID // 4011-P',
        timestamp: _getCurrentTimestamp(offsetMinutes: -6),
        content: 'Market volatility alert: Crude Oil futures surge 1.2% in 4 mins.',
        tags: ['ECON', 'CRITICAL'],
        severity: 'critical',
      ),
      FeedDataModel(
        id: 'OP-ID // 9920-W',
        timestamp: _getCurrentTimestamp(offsetMinutes: -22),
        content: 'Constellation SIGMA repositioning complete. 100% throughput.',
        tags: ['SYSTEM', 'AUTO'],
        severity: 'normal',
      ),
      FeedDataModel(
        id: 'GEO-ID // 5541-K',
        timestamp: _getCurrentTimestamp(offsetMinutes: -34),
        content: 'Diplomatic communication surge detected between G7 nodes. Pattern analysis suggests coordinated policy response.',
        tags: ['DIPLO', 'G7'],
        severity: 'warning',
      ),
      FeedDataModel(
        id: 'CY-ID // 7720-R',
        timestamp: _getCurrentTimestamp(offsetMinutes: -49),
        content: 'Distributed denial-of-service attempt neutralized at Gateway Node 7. All systems nominal.',
        tags: ['CYBER', 'DEFENSE'],
        severity: 'critical',
      ),
      FeedDataModel(
        id: 'MK-ID // 3301-E',
        timestamp: _getCurrentTimestamp(offsetMinutes: -66),
        content: 'Gold futures showing unusual correlation with crypto asset class. Cross-market anomaly flagged.',
        tags: ['MARKET', 'ANOMALY'],
        severity: 'normal',
      ),
    ];
  }

  /// Simulate real-time feed update (senkron - no async for Timer compatibility)
  FeedDataModel generateNewFeedItem() {
    _feedCounter++;
    
    // Generate simulation data (API calls removed for Timer compatibility)
    final random = Random();
    final content = _contents[random.nextInt(_contents.length)];
    final severity = _severities[random.nextInt(_severities.length)];
    
    final tagList = <String>[];
    for (int i = 0; i < 2; i++) {
      tagList.add(_tags[random.nextInt(_tags.length)]);
    }

    return FeedDataModel(
      id: 'RT-ID // ${_generateRandomId()}',
      timestamp: _getCurrentTimestamp(),
      content: content,
      tags: tagList.toSet().toList(),
      severity: severity,
    );
  }

  /// Check if real-time API is available
  bool get isRealTimeAvailable => _realTimeService.isConfigured;

  /// Apply AI analysis using queue system (async - for initial load)
  /// Enqueues items with priority and returns when all are processed
  Future<List<FeedDataModel>> applyAIAnalysis(List<FeedDataModel> items) async {
    // Deduplicate first
    final uniqueItems = _aiService.deduplicate(items);
    
    // Enqueue all items with high priority for initial load
    final results = await _aiService.analyzeBatch(uniqueItems, highPriority: true);
    
    // Build analyzed items from results
    final analyzedItems = <FeedDataModel>[];
    for (final item in uniqueItems) {
      final analysis = results[item.id];
      if (analysis != null) {
        analyzedItems.add(FeedDataModel(
          id: item.id,
          timestamp: item.timestamp,
          content: item.content,
          tags: item.tags,
          severity: analysis.verificationTier == 'SUSPICIOUS' ? 'warning' : item.severity,
          sourceDomain: item.sourceDomain,
          publishedAt: item.publishedAt,
          url: item.url,
          verificationStatus: analysis.verificationTier,
          crossSources: item.crossSources,
          aiVerificationTier: analysis.verificationTier,
          aiSummary: analysis.aiSummary,
          aiRedFlags: analysis.redFlags,
          aiTrustIndicators: analysis.trustIndicators,
        ));
      } else {
        // Keep original if analysis failed
        analyzedItems.add(item);
      }
    }
    
    debugPrint('✅ AI analysis complete for ${analyzedItems.length} items');
    return analyzedItems;
  }

  /// Enqueue single item for AI analysis (returns immediately, processes in background)
  Future<AIAnalysisResult> enqueueAIAnalysis(FeedDataModel item, {bool highPriority = false}) {
    return _aiService.analyzeNews(item, highPriority: highPriority);
  }

  /// Get current queue status for UI display
  QueueStatus get aiQueueStatus => _aiService.queueStatus;
  QueueStatistics get aiQueueStatistics => _aiService.queueStatistics;

  /// Listen to queue status changes
  void addQueueListener(Function(QueueStatus) listener) {
    _aiService.addQueueListener(listener);
  }

  void removeQueueListener(Function(QueueStatus) listener) {
    _aiService.removeQueueListener(listener);
  }

  /// Control queue operations
  void pauseAIQueue() => _aiService.pauseQueue();
  void resumeAIQueue() => _aiService.resumeQueue();
  void clearAIQueue() => _aiService.clearQueue();
  void retryFailedAI() => _aiService.retryFailed();

  /// Quick AI analysis (sync - for timer updates, uses local only)
  FeedDataModel applyQuickAIAnalysis(FeedDataModel item) {
    final analysis = _aiService.analyzeNewsSync(item);
    return FeedDataModel(
      id: item.id,
      timestamp: item.timestamp,
      content: item.content,
      tags: item.tags,
      severity: analysis.verificationTier == 'SUSPICIOUS' ? 'warning' : item.severity,
      sourceDomain: item.sourceDomain,
      publishedAt: item.publishedAt,
      url: item.url,
      verificationStatus: analysis.verificationTier,
      crossSources: item.crossSources,
      aiVerificationTier: analysis.verificationTier,
      aiSummary: analysis.aiSummary,
      aiRedFlags: analysis.redFlags,
      aiTrustIndicators: analysis.trustIndicators,
    );
  }

  String _getCurrentTimestamp({int offsetMinutes = 0}) {
    final now = DateTime.now().add(Duration(minutes: -offsetMinutes));
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  String _generateRandomId() {
    final random = Random();
    final letters = String.fromCharCodes(
      List.generate(4, (_) => 65 + random.nextInt(26)),
    );
    final numbers = random.nextInt(9000) + 1000;
    return '$numbers-$letters';
  }
}

