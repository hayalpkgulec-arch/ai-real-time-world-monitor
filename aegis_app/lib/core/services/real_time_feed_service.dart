import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'feed_data_service.dart';

/// Real-time news and intelligence data service using actual APIs
class RealTimeFeedService {
  static final RealTimeFeedService _instance = RealTimeFeedService._internal();
  factory RealTimeFeedService() => _instance;
  RealTimeFeedService._internal();

  final String _baseUrl = 'https://newsapi.org/v2';
  String? _apiKey;

  /// Initialize with API key
  void initialize() {
    _apiKey = dotenv.env['NEWS_API_KEY'];
  }

  /// Check if API is configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty && _apiKey != 'your_news_api_key_here';

  /// Fetch real-time news based on intelligence keywords
  Future<List<FeedDataModel>> fetchIntelligenceNews() async {
    if (!isConfigured) {
      throw Exception('News API key not configured. Please add your API key to .env file');
    }

    // Keywords for intelligence-relevant news
    final keywords = [
      'conflict',
      'cybersecurity',
      'economy',
      'geopolitics',
      'security',
      'intelligence',
    ];

    final query = keywords.join(' OR ');
    final url = Uri.parse(
      '$_baseUrl/everything?q=$query&sortBy=publishedAt&language=en&pageSize=20&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List<dynamic>;

        return articles.map((article) => _convertArticleToFeedItem(article)).toList();
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please wait a moment.');
      } else {
        throw Exception('Failed to fetch news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch top headlines for critical alerts
  Future<List<FeedDataModel>> fetchCriticalHeadlines() async {
    if (!isConfigured) {
      throw Exception('News API key not configured');
    }

    final url = Uri.parse(
      '$_baseUrl/top-headlines?category=general&pageSize=10&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List<dynamic>;

        return articles
            .where((a) => a['title'] != '[Removed]')
            .map((article) => _convertArticleToFeedItem(article, isCritical: true))
            .toList();
      } else {
        throw Exception('Failed to fetch headlines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Convert news article to feed item format
  FeedDataModel _convertArticleToFeedItem(Map<String, dynamic> article, {bool isCritical = false}) {
    final title = article['title'] ?? 'Untitled';
    final description = article['description'] ?? '';
    final publishedAt = article['publishedAt'] ?? DateTime.now().toIso8601String();
    final source = article['source']?['name'] ?? 'Unknown';
    final url = article['url'] ?? '';

    // Parse timestamp
    final dateTime = DateTime.tryParse(publishedAt) ?? DateTime.now();
    final timestamp = 
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';

    // Determine severity based on content analysis
    String severity = 'normal';
    if (isCritical) {
      severity = 'critical';
    } else {
      final content = '$title $description'.toLowerCase();
      if (content.contains('breaking') || 
          content.contains('urgent') || 
          content.contains('crisis') ||
          content.contains('attack') ||
          content.contains('war')) {
        severity = 'critical';
      } else if (content.contains('alert') || 
                 content.contains('warning') || 
                 content.contains('threat')) {
        severity = 'warning';
      }
    }

    // Generate tags based on content
    final tags = _generateTags(title, description);

    // Extract source domain from URL
    String? sourceDomain;
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        sourceDomain = uri.host.replaceAll('www.', '');
      } catch (_) {
        sourceDomain = source.toLowerCase().replaceAll(' ', '');
      }
    }

    // Determine age-based verification status
    String verificationStatus = 'SINGLE_SOURCE';
    final ageInHours = DateTime.now().difference(dateTime).inHours;
    if (ageInHours < 1) {
      verificationStatus = 'FRESH';
    } else if (ageInHours > 24) {
      verificationStatus = 'STALE';
    }

    // Generate ID
    final id = 'NEWS-${dateTime.millisecondsSinceEpoch % 10000}';

    return FeedDataModel(
      id: id,
      timestamp: timestamp,
      content: '$title - $description',
      tags: tags,
      severity: severity,
      sourceDomain: sourceDomain,
      publishedAt: dateTime,
      url: url.isNotEmpty ? url : null,
      verificationStatus: verificationStatus,
    );
  }

  /// Generate intelligence tags based on content
  List<String> _generateTags(String title, String description) {
    final content = '$title $description'.toLowerCase();
    final tags = <String>[];

    final tagMappings = {
      'POLITICAL': ['politic', 'election', 'government', 'policy', 'diplomat'],
      'ECON': ['economy', 'market', 'stock', 'trade', 'finance', 'crypto', 'bitcoin'],
      'CYBER': ['cyber', 'hack', 'security breach', 'malware', 'ransomware'],
      'CONFLICT': ['war', 'military', 'attack', 'defense', 'weapon', 'invasion'],
      'CLIMATE': ['climate', 'weather', 'disaster', 'earthquake', 'hurricane', 'flood'],
      'TECH': ['technology', 'ai', 'artificial intelligence', 'tech', 'digital'],
      'HEALTH': ['health', 'pandemic', 'virus', 'disease', 'medical'],
    };

    tagMappings.forEach((tag, keywords) {
      if (keywords.any((k) => content.contains(k))) {
        tags.add(tag);
      }
    });

    // Add source tag
    tags.add('NEWS');

    return tags.isEmpty ? ['GENERAL', 'NEWS'] : tags;
  }
}
