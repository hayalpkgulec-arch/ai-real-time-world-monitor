import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Web search service for AI news verification
/// Calls backend API to avoid CORS issues and keep API keys secure
class WebSearchService {
  static final WebSearchService _instance = WebSearchService._internal();
  factory WebSearchService() => _instance;
  WebSearchService._internal();

  // Backend Configuration
  String? _backendUrl;
  bool _isConfigured = false;

  /// Initialize the service
  void initialize() {
    _backendUrl = dotenv.env['BACKEND_URL'];
    _isConfigured = _backendUrl != null && _backendUrl!.isNotEmpty;
    
    if (_isConfigured) {
      debugPrint('✅ Backend API configured: $_backendUrl');
    } else {
      debugPrint('⚠️ Backend API not configured - using simulation mode');
      debugPrint('   Set BACKEND_URL in .env to enable real web search');
    }
  }

  bool get isConfigured => _isConfigured;

  /// Search for news verification via backend API
  Future<NewsVerificationResult> verifyNews(
    String content,
    String? sourceDomain,
  ) async {
    if (!_isConfigured) {
      return _simulateVerification(content, sourceDomain);
    }

    try {
      // Call backend verification endpoint
      final response = await http.post(
        Uri.parse('$_backendUrl/api/verify-news'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': content,
          'sourceDomain': sourceDomain,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return NewsVerificationResult(
            isVerified: data['isVerified'] ?? false,
            verificationStatus: data['verificationStatus'] ?? 'UNVERIFIED',
            credibleSourceCount: data['credibleSourceCount'] ?? 0,
            matchingSourceCount: data['matchingSourceCount'] ?? 0,
            supportingUrls: List<String>.from(data['supportingUrls'] ?? []),
            contradictions: List<String>.from(data['contradictions'] ?? []),
            credibilityBoost: data['credibilityBoost'] ?? 0,
            searchQuery: data['searchQuery'] ?? '',
            isRealSearch: !(data['isSimulated'] ?? false),
          );
        }
      }
      
      // Fallback to simulation on error
      debugPrint('⚠️ Backend verification failed, using simulation');
      return _simulateVerification(content, sourceDomain);
      
    } catch (e) {
      debugPrint('⚠️ Web search error: $e');
      return _simulateVerification(content, sourceDomain);
    }
  }

  /// Simulate verification when backend is not available
  NewsVerificationResult _simulateVerification(
    String content,
    String? sourceDomain,
  ) {
    final reputableSources = [
      'reuters.com', 'bloomberg.com', 'apnews.com', 'bbc.com',
      'cnn.com', 'ft.com', 'wsj.com', 'nytimes.com',
    ];

    final isReputable = sourceDomain != null &&
        reputableSources.any((s) => sourceDomain.contains(s));

    if (isReputable) {
      return NewsVerificationResult(
        isVerified: true,
        verificationStatus: 'LIKELY_TRUE',
        credibleSourceCount: 1,
        matchingSourceCount: 1,
        supportingUrls: ['https://$sourceDomain'],
        contradictions: [],
        credibilityBoost: 15,
        searchQuery: '',
        isRealSearch: false,
      );
    }

    return NewsVerificationResult(
      isVerified: false,
      verificationStatus: 'UNVERIFIED',
      credibleSourceCount: 0,
      matchingSourceCount: 0,
      supportingUrls: [],
      contradictions: [],
      credibilityBoost: 0,
      searchQuery: '',
      isRealSearch: false,
    );
  }
}

/// News verification result from web search
class NewsVerificationResult {
  final bool isVerified;
  final String verificationStatus;
  final int credibleSourceCount;
  final int matchingSourceCount;
  final List<String> supportingUrls;
  final List<String> contradictions;
  final int credibilityBoost;
  final String searchQuery;
  final bool isRealSearch;

  NewsVerificationResult({
    required this.isVerified,
    required this.verificationStatus,
    required this.credibleSourceCount,
    required this.matchingSourceCount,
    required this.supportingUrls,
    required this.contradictions,
    required this.credibilityBoost,
    required this.searchQuery,
    required this.isRealSearch,
  });

  String get summary {
    if (isVerified) {
      return 'Verified by $credibleSourceCount credible sources';
    } else if (matchingSourceCount > 0) {
      return 'Supported by $matchingSourceCount source(s)';
    } else {
      return 'Limited verification available';
    }
  }

  Map<String, dynamic> toJson() => {
    'isVerified': isVerified,
    'verificationStatus': verificationStatus,
    'credibleSourceCount': credibleSourceCount,
    'matchingSourceCount': matchingSourceCount,
    'supportingUrls': supportingUrls,
    'contradictions': contradictions,
    'credibilityBoost': credibilityBoost,
    'searchQuery': searchQuery,
    'isRealSearch': isRealSearch,
  };
}
