import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'feed_data_service.dart';
import 'web_search_service.dart';

/// AI-powered news analysis and verification service
/// Uses backend proxy with multi-provider fallback (OpenRouter, Groq, Mistral, Local)
/// Now with built-in intelligent queue system for optimized processing
class AIAnalysisService {
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal() {
    _initializeBackend();
    _webSearchService.initialize();
  }

  // Backend Configuration
  String? _backendUrl;
  bool _isBackendConfigured = false;
  
  final WebSearchService _webSearchService = WebSearchService();

  // Queue System - integrated to avoid circular dependencies
  static const int _maxConcurrent = 3;
  static const int _maxRetries = 2;
  static const Duration _processInterval = Duration(milliseconds: 100);
  static const Duration _retryDelay = Duration(seconds: 5);

  final List<_AIQueueItem> _queue = [];
  final List<_AIQueueItem> _processing = [];
  final List<_AIQueueItem> _completed = [];
  final List<_AIQueueItem> _failed = [];
  bool _isProcessing = false;
  Timer? _processTimer;
  int _totalProcessed = 0;
  int _totalFailed = 0;
  final List<Function(QueueStatus)> _statusListeners = [];

  /// Queue status for monitoring
  QueueStatus get queueStatus => QueueStatus(
    pending: _queue.length,
    processing: _processing.length,
    completed: _completed.length,
    failed: _failed.length,
    totalProcessed: _totalProcessed,
    totalFailed: _totalFailed,
    isActive: _isProcessing,
  );

  QueueStatistics get queueStatistics {
    final avgProcessingTime = _completed.isEmpty 
      ? 0 
      : _completed.fold<int>(
          0, 
          (sum, item) => sum + DateTime.now().difference(item.addedAt).inSeconds,
        ) ~/ _completed.length;

    return QueueStatistics(
      totalProcessed: _totalProcessed,
      totalFailed: _totalFailed,
      successRate: _totalProcessed == 0 
        ? 0 
        : (_totalProcessed / (_totalProcessed + _totalFailed) * 100).round(),
      averageProcessingTime: avgProcessingTime,
      queueDepth: _queue.length,
    );
  }

  /// Initialize backend URL from environment
  void _initializeBackend() {
    _backendUrl = dotenv.env['BACKEND_URL'];
    _isBackendConfigured = _backendUrl != null && _backendUrl!.isNotEmpty;
    
    if (_isBackendConfigured) {
      debugPrint('✅ AI Backend API configured: $_backendUrl');
    } else {
      debugPrint('⚠️ Backend not configured, using local analysis only');
    }
  }

  /// Check if backend AI service is configured
  bool get isAIConfigured => _isBackendConfigured;

  /// Analyze news item with AI using queue system
  Future<AIAnalysisResult> analyzeNews(FeedDataModel news, {bool highPriority = false}) async {
    return _enqueue(news, highPriority: highPriority);
  }

  /// Synchronous version for Timer compatibility (always uses local analysis)
  AIAnalysisResult analyzeNewsSync(FeedDataModel news) {
    return _performLocalAnalysis(news);
  }

  /// Batch analyze with queue
  Future<Map<String, AIAnalysisResult>> analyzeBatch(
    List<FeedDataModel> newsItems, {
    bool highPriority = false,
  }) async {
    final results = <String, AIAnalysisResult>{};
    final futures = <Future<void>>[];

    for (final news in newsItems) {
      futures.add(
        _enqueue(news, highPriority: highPriority).then(
          (result) => results[news.id] = result,
        ).catchError((error) {
          debugPrint('❌ Queue error for ${news.id}: $error');
          return AIAnalysisResult(
            credibilityScore: 0,
            verificationTier: 'ERROR',
            aiSummary: 'Analysis failed',
            redFlags: ['Queue error'],
            trustIndicators: [],
            analyzedAt: DateTime.now(),
          );
        }),
      );
    }

    await Future.wait(futures);
    return results;
  }

  /// Add item to queue
  Future<AIAnalysisResult> _enqueue(FeedDataModel news, {bool highPriority = false}) {
    final completer = Completer<AIAnalysisResult>();

    final item = _AIQueueItem(
      news: news,
      priority: highPriority ? 1000 : 0,
      onComplete: (result) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );

    _queue.add(item);
    _sortQueue();
    _notifyStatusListeners();
    debugPrint('📥 Added to queue: ${news.id} (priority: ${item.priorityScore})');
    _startProcessing();

    return completer.future;
  }

  void _sortQueue() {
    _queue.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
  }

  void _startProcessing() {
    if (_isProcessing) return;
    _isProcessing = true;
    _processTimer?.cancel();
    _processTimer = Timer.periodic(_processInterval, (_) => _processQueue());
    debugPrint('▶️ AI Analysis Queue started');
    _notifyStatusListeners();
  }

  void _processQueue() async {
    if (!_isProcessing) return;
    if (_queue.isEmpty && _processing.isEmpty) {
      if (_completed.length > 100) {
        _completed.removeRange(0, _completed.length - 50);
      }
      return;
    }

    while (_processing.length < _maxConcurrent && _queue.isNotEmpty) {
      _sortQueue();
      final item = _queue.removeAt(0);
      item.status = _AnalysisStatus.processing;
      _processing.add(item);
      _processItem(item);
    }

    _notifyStatusListeners();
  }

  Future<void> _processItem(_AIQueueItem item) async {
    try {
      debugPrint('🔍 Processing: ${item.news.id} (queue: ${_queue.length})');
      
      AIAnalysisResult result;
      if (isAIConfigured) {
        try {
          result = await _callBackendAI(item.news);
        } catch (e) {
          debugPrint('⚠️ Backend AI error: $e. Using local analysis.');
          result = _performLocalAnalysis(item.news);
        }
      } else {
        result = _performLocalAnalysis(item.news);
      }
      
      item.status = _AnalysisStatus.completed;
      _processing.remove(item);
      _completed.add(item);
      _totalProcessed++;
      item.onComplete?.call(result);
      
      debugPrint('✅ Completed: ${item.news.id} (${result.verificationTier})');
    } catch (error) {
      debugPrint('❌ Failed: ${item.news.id} - $error');
      _processing.remove(item);
      
      if (item.retryCount < _maxRetries) {
        item.retryCount++;
        item.status = _AnalysisStatus.retrying;
        debugPrint('🔄 Retrying ${item.news.id} (attempt ${item.retryCount})');
        await Future.delayed(_retryDelay * item.retryCount);
        _queue.add(item);
      } else {
        item.status = _AnalysisStatus.failed;
        _failed.add(item);
        _totalFailed++;
        item.onError?.call(error);
      }
    }
    
    _notifyStatusListeners();
  }

  /// Pause the queue
  void pauseQueue() {
    _isProcessing = false;
    _processTimer?.cancel();
    debugPrint('⏸️ AI Analysis Queue paused');
    _notifyStatusListeners();
  }
  
  /// Resume the queue
  void resumeQueue() {
    if (_queue.isNotEmpty || _processing.isNotEmpty) {
      _startProcessing();
    }
  }
  
  /// Clear pending items
  void clearQueue() {
    _queue.clear();
    debugPrint('🧹 Queue cleared');
    _notifyStatusListeners();
  }
  
  /// Retry failed items
  void retryFailed() {
    for (final item in _failed.toList()) {
      item.retryCount = 0;
      item.status = _AnalysisStatus.pending;
      _queue.add(item);
    }
    _failed.clear();
    _startProcessing();
    debugPrint('🔄 Retrying ${_queue.length} failed items');
    _notifyStatusListeners();
  }

  /// Add status listener
  void addQueueListener(Function(QueueStatus) listener) {
    _statusListeners.add(listener);
    listener(queueStatus);
  }

  void removeQueueListener(Function(QueueStatus) listener) {
    _statusListeners.remove(listener);
  }

  void _notifyStatusListeners() {
    final status = queueStatus;
    for (final listener in _statusListeners) {
      listener(status);
    }
  }

  /// Stop and cleanup
  void dispose() {
    _isProcessing = false;
    _processTimer?.cancel();
    _statusListeners.clear();
    _queue.clear();
    _processing.clear();
    _completed.clear();
    _failed.clear();
  }

  /// Internal method for queue to call backend AI
  Future<AIAnalysisResult> _callBackendAI(FeedDataModel news) async {
    // First, research the news on the web
    debugPrint('🔍 Researching news: ${news.content.substring(0, news.content.length > 50 ? 50 : news.content.length)}...');
    final webResult = await _webSearchService.verifyNews(news.content, news.sourceDomain);
    
    // Call backend AI analysis endpoint
    final response = await http.post(
      Uri.parse('$_backendUrl/api/ai/analyze'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': news.content,
        'sourceDomain': news.sourceDomain,
        'webResults': {
          'credibleSourceCount': webResult.credibleSourceCount,
          'matchingSourceCount': webResult.matchingSourceCount,
          'verificationStatus': webResult.verificationStatus,
          'credibilityBoost': webResult.credibilityBoost,
        },
      }),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        // Combine AI score with web verification boost
        int baseScore = (data['credibilityScore'] as num).toInt().clamp(0, 100);
        int finalScore = (baseScore + webResult.credibilityBoost).clamp(0, 100);

        return AIAnalysisResult(
          credibilityScore: finalScore,
          verificationTier: _simplifyVerificationTier(data['verificationTier'] ?? webResult.verificationStatus),
          aiSummary: data['aiSummary'] ?? webResult.summary,
          redFlags: List<String>.from(data['redFlags'] ?? []),
          trustIndicators: [...List<String>.from(data['trustIndicators'] ?? []), 
            if (webResult.credibleSourceCount > 0) 'Web verified: ${webResult.credibleSourceCount} sources'],
          analyzedAt: DateTime.now(),
          modelUsed: data['provider'] ?? 'unknown',
          isRealAI: data['provider'] != 'local',
          webSearchResult: webResult,
        );
      }
    }
    
    throw Exception('Backend AI error: ${response.statusCode}');
  }

  /// Local rule-based analysis (fallback when AI API unavailable)
  AIAnalysisResult _performLocalAnalysis(FeedDataModel news) {
    int credibilityScore = 50; // Base score
    final List<String> redFlags = [];
    final List<String> trustIndicators = [];

    // 1. Source reputation check
    final reputableSources = [
      'reuters.com', 'bloomberg.com', 'apnews.com', 'afp.com',
      'bbc.com', 'cnn.com', 'ft.com', 'wsj.com', 'nytimes.com',
      'economist.com', 'forbes.com', 'cnbc.com', 'aljazeera.com',
      'theguardian.com', 'washingtonpost.com', 'time.com',
    ];

    if (news.sourceDomain != null) {
      if (reputableSources.any((s) => news.sourceDomain!.contains(s))) {
        credibilityScore += 25;
        trustIndicators.add('Reputable source');
      } else if (news.sourceDomain!.contains('blog') ||
                 news.sourceDomain!.contains('forum')) {
        credibilityScore -= 20;
        redFlags.add('User-generated content');
      }
    }

    // 2. Content freshness check
    if (news.isRealtime) {
      credibilityScore += 10;
      trustIndicators.add('Breaking news');
    } else if (!news.isFresh && news.ageInMinutes != null && news.ageInMinutes! > 1440) {
      credibilityScore -= 5;
      redFlags.add('Old news (>24h)');
    }

    // 3. Content quality indicators
    final content = news.content.toLowerCase();
    if (content.contains('official') || content.contains('confirmed')) {
      credibilityScore += 10;
      trustIndicators.add('Official confirmation');
    }
    if (content.contains('rumor') || content.contains('unconfirmed') ||
        content.contains('allegedly')) {
      credibilityScore -= 15;
      redFlags.add('Unverified claims');
    }
    if (content.contains('breaking') || content.contains('urgent')) {
      credibilityScore += 5;
    }

    // 4. Fact-check database simulation
    final factCheckResult = _checkFactDatabase(news.content);
    if (factCheckResult != null) {
      if (factCheckResult.isVerified) {
        credibilityScore += 20;
        trustIndicators.add('Fact-checked');
      } else {
        credibilityScore -= 30;
        redFlags.add('Fact-check: Misleading');
      }
    }

    // 5. Sentiment and manipulation analysis
    if (_containsSensationalLanguage(content)) {
      credibilityScore -= 10;
      redFlags.add('Sensational language');
    }

    // Clamp score to 0-100
    credibilityScore = credibilityScore.clamp(0, 100);

    // Determine verification tier (simplified to only VERIFIED or SUSPICIOUS)
    String verificationTier;
    if (credibilityScore >= 60) {
      verificationTier = 'VERIFIED';
    } else {
      verificationTier = 'SUSPICIOUS';
    }

    // Generate AI summary
    final aiSummary = _generateAISummary(news, credibilityScore);

    return AIAnalysisResult(
      credibilityScore: credibilityScore,
      verificationTier: verificationTier,
      aiSummary: aiSummary,
      redFlags: redFlags,
      trustIndicators: trustIndicators,
      analyzedAt: DateTime.now(),
      modelUsed: 'local-rule-based',
      isRealAI: false,
    );
  }

  /// Check against simulated fact-check database
  FactCheckResult? _checkFactDatabase(String content) {
    // Simulated fact-check database
    final knownFacts = {
      'earth is flat': false,
      'vaccines cause autism': false,
      'climate change is hoax': false,
    };

    final lowerContent = content.toLowerCase();
    for (final entry in knownFacts.entries) {
      if (lowerContent.contains(entry.key)) {
        return FactCheckResult(
          claim: entry.key,
          isVerified: entry.value,
          source: 'FactCheck.org',
        );
      }
    }
    return null;
  }

  /// Detect sensational/manipulative language
  bool _containsSensationalLanguage(String content) {
    final sensationalWords = [
      'shocking', 'unbelievable', 'mind-blowing', 'you won\'t believe',
      'doctors hate this', 'secret they don\'t want you to know',
    ];
    return sensationalWords.any((w) => content.contains(w));
  }

  /// Generate AI-powered summary
  String _generateAISummary(FeedDataModel news, int score) {
    final buffer = StringBuffer();

    // Context analysis
    if (news.tags.contains('CONFLICT')) {
      buffer.write('Geopolitical development. ');
    } else if (news.tags.contains('ECON')) {
      buffer.write('Market-moving event. ');
    } else if (news.tags.contains('CYBER')) {
      buffer.write('Security incident. ');
    }

    // Credibility assessment
    if (score >= 80) {
      buffer.write('High credibility. Multiple reliable indicators present.');
    } else if (score >= 60) {
      buffer.write('Moderate credibility. Some verification needed.');
    } else if (score >= 40) {
      buffer.write('Limited verification. Exercise caution.');
    } else {
      buffer.write('Low credibility. Verify from additional sources.');
    }

    return buffer.toString();
  }

  /// Simplify verification tier to only VERIFIED or SUSPICIOUS
  String _simplifyVerificationTier(String? tier) {
    if (tier == null) return 'SUSPICIOUS';
    switch (tier.toUpperCase()) {
      case 'VERIFIED':
      case 'FRESH':
      case 'LIKELY_TRUE':
        return 'VERIFIED';
      case 'SUSPICIOUS':
      case 'UNVERIFIED':
      case 'SINGLE_SOURCE':
      case 'STALE':
      default:
        return 'SUSPICIOUS';
    }
  }

  /// Detect similar/duplicate news (deduplication)
  List<FeedDataModel> deduplicate(List<FeedDataModel> items) {
    final seen = <String>[];
    final unique = <FeedDataModel>[];

    for (final item in items) {
      // Create content fingerprint
      final fingerprint = _createFingerprint(item.content);

      // Check similarity with existing items
      bool isDuplicate = false;
      for (final existing in seen) {
        if (_calculateSimilarity(fingerprint, existing) > 0.7) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate) {
        seen.add(fingerprint);
        unique.add(item);
      }
    }

    return unique;
  }

  /// Create text fingerprint for deduplication
  String _createFingerprint(String text) {
    // Simple fingerprint: lowercase, remove punctuation, take first 50 chars
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .take(10)
        .join(' ');
  }

  /// Calculate similarity between two fingerprints (0.0 - 1.0)
  double _calculateSimilarity(String a, String b) {
    final wordsA = a.split(' ').toSet();
    final wordsB = b.split(' ').toSet();
    final intersection = wordsA.intersection(wordsB).length;
    final union = wordsA.union(wordsB).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  /// Cross-reference news across multiple sources
  Future<CrossReferenceResult> crossReference(FeedDataModel news) async {
    final supportingSources = <String>[];
    final conflictingSources = <String>[];

    // Simulate checking other news APIs
    // In production: Query GDELT, Event Registry, etc.

    // For now, simulate based on news tags
    if (news.tags.contains('CONFLICT')) {
      supportingSources.addAll(['Reuters', 'BBC']);
    }
    if (news.tags.contains('ECON')) {
      supportingSources.addAll(['Bloomberg', 'FT']);
    }

    return CrossReferenceResult(
      originalNews: news,
      supportingSources: supportingSources,
      conflictingSources: conflictingSources,
      consensusLevel: supportingSources.length >= 2 ? 'HIGH' : 'LOW',
    );
  }
}

/// AI analysis result for a news item
class AIAnalysisResult {
  final int credibilityScore; // 0-100
  final String verificationTier; // VERIFIED, LIKELY_TRUE, UNVERIFIED, SUSPICIOUS
  final String aiSummary;
  final List<String> redFlags;
  final List<String> trustIndicators;
  final DateTime analyzedAt;
  final String? modelUsed; // Which AI model was used
  final bool isRealAI; // True if from API, false if local analysis
  final NewsVerificationResult? webSearchResult; // Web verification data

  AIAnalysisResult({
    required this.credibilityScore,
    required this.verificationTier,
    required this.aiSummary,
    required this.redFlags,
    required this.trustIndicators,
    required this.analyzedAt,
    this.modelUsed,
    this.isRealAI = false,
    this.webSearchResult,
  });

  Map<String, dynamic> toJson() => {
    'credibilityScore': credibilityScore,
    'verificationTier': verificationTier,
    'aiSummary': aiSummary,
    'redFlags': redFlags,
    'trustIndicators': trustIndicators,
    'analyzedAt': analyzedAt.toIso8601String(),
    'modelUsed': modelUsed,
    'isRealAI': isRealAI,
    'webSearchResult': webSearchResult?.toJson(),
  };
}

/// Fact-check result
class FactCheckResult {
  final String claim;
  final bool isVerified;
  final String source;

  FactCheckResult({
    required this.claim,
    required this.isVerified,
    required this.source,
  });
}

/// Cross-reference analysis result
class CrossReferenceResult {
  final FeedDataModel originalNews;
  final List<String> supportingSources;
  final List<String> conflictingSources;
  final String consensusLevel; // HIGH, MEDIUM, LOW

  CrossReferenceResult({
    required this.originalNews,
    required this.supportingSources,
    required this.conflictingSources,
    required this.consensusLevel,
  });

  bool get isCrossVerified => supportingSources.length >= 2;
}

/// Queue status enum
enum _AnalysisStatus {
  pending,
  processing,
  completed,
  failed,
  retrying,
}

/// Internal queue item for AI analysis
class _AIQueueItem {
  final FeedDataModel news;
  final DateTime addedAt;
  final int priority;
  final Function(AIAnalysisResult)? onComplete;
  final Function(Object)? onError;
  int retryCount;
  _AnalysisStatus status;

  _AIQueueItem({
    required this.news,
    required this.priority,
    this.onComplete,
    this.onError,
    this.retryCount = 0,
    this.status = _AnalysisStatus.pending,
  }) : addedAt = DateTime.now();

  int get priorityScore {
    int score = priority;
    if (news.isRealtime) score += 100;
    else if (news.isFresh) score += 50;
    if (news.ageInMinutes != null) {
      score -= (news.ageInMinutes! ~/ 10);
    }
    final waitTime = DateTime.now().difference(addedAt).inSeconds;
    score += (waitTime ~/ 30);
    return score;
  }
}

/// Queue status for UI display
class QueueStatus {
  final int pending;
  final int processing;
  final int completed;
  final int failed;
  final int totalProcessed;
  final int totalFailed;
  final bool isActive;

  QueueStatus({
    required this.pending,
    required this.processing,
    required this.completed,
    required this.failed,
    required this.totalProcessed,
    required this.totalFailed,
    required this.isActive,
  });

  int get total => pending + processing + completed + failed;
  bool get isEmpty => total == 0;
  bool get hasPending => pending > 0 || processing > 0;
  double get progress => total == 0 ? 0 : (completed / total);

  @override
  String toString() {
    return 'Queue: $pending pending, $processing processing, $completed completed, $failed failed';
  }
}

/// Queue statistics
class QueueStatistics {
  final int totalProcessed;
  final int totalFailed;
  final int successRate;
  final int averageProcessingTime;
  final int queueDepth;

  QueueStatistics({
    required this.totalProcessed,
    required this.totalFailed,
    required this.successRate,
    required this.averageProcessingTime,
    required this.queueDepth,
  });
}
