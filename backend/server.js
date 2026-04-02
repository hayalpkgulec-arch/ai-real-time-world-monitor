/**
 * AEGIS Intelligence Backend API
 * Production-ready proxy service for news verification
 * 
 * Features:
 * - SerpAPI proxy with rate limiting
 * - CORS enabled for mobile/web apps
 * - Security headers (Helmet)
 * - Request logging (Morgan)
 * - Compression
 * - Error handling
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const morgan = require('morgan');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Environment variables
const SERP_API_KEY = process.env.SERP_API_KEY;
const MISTRAL_API_KEY = process.env.MISTRAL_API_KEY;
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
const GROQ_API_KEY = process.env.GROQ_API_KEY;
const ALLOWED_ORIGINS = process.env.ALLOWED_ORIGINS?.split(',') || ['*'];

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false, // Disable for API
  crossOriginEmbedderPolicy: false,
}));

// CORS configuration
app.use(cors({
  origin: ALLOWED_ORIGINS.includes('*') ? '*' : ALLOWED_ORIGINS,
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
  credentials: true,
}));

// Compression
app.use(compression());

// Request logging
app.use(morgan(NODE_ENV === 'production' ? 'combined' : 'dev'));

// Parse JSON
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 60, // 60 requests per minute
  message: {
    error: 'Too many requests',
    message: 'Please try again later',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Stricter rate limit for expensive operations
const searchLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 20, // 20 searches per minute
  message: {
    error: 'Search limit exceeded',
    message: 'Maximum 20 searches per minute allowed',
  },
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    environment: NODE_ENV,
  });
});

// API status endpoint
app.get('/api/status', (req, res) => {
  res.json({
    status: 'operational',
    services: {
      serpApi: !!SERP_API_KEY,
      mistralAi: !!MISTRAL_API_KEY,
    },
    rateLimits: {
      general: '60 requests/minute',
      search: '20 searches/minute',
    },
  });
});

// Web search proxy endpoint
app.get('/api/search', searchLimiter, async (req, res) => {
  try {
    const { q, num = 10 } = req.query;

    if (!q) {
      return res.status(400).json({
        error: 'Missing query parameter',
        message: 'Query parameter "q" is required',
      });
    }

    if (!SERP_API_KEY) {
      return res.status(503).json({
        error: 'Service unavailable',
        message: 'Search service not configured',
      });
    }

    // Call SerpAPI
    const response = await axios.get('https://serpapi.com/search', {
      params: {
        q: q,
        api_key: SERP_API_KEY,
        num: Math.min(parseInt(num) || 10, 20), // Max 20 results
        engine: 'google',
      },
      timeout: 10000, // 10 second timeout
    });

    // Transform and return results
    const results = response.data.organic_results?.map(result => ({
      title: result.title,
      url: result.link,
      snippet: result.snippet,
      source: extractDomain(result.link),
      displayedUrl: result.displayed_link,
    })) || [];

    res.json({
      success: true,
      query: q,
      totalResults: results.length,
      results: results,
      searchMetadata: {
        processedAt: new Date().toISOString(),
        engine: 'google',
      },
    });

  } catch (error) {
    console.error('Search error:', error.message);
    
    if (error.response?.status === 401) {
      return res.status(500).json({
        error: 'API configuration error',
        message: 'Invalid API key configuration',
      });
    }

    if (error.code === 'ECONNABORTED') {
      return res.status(504).json({
        error: 'Gateway timeout',
        message: 'Search service timed out',
      });
    }

    res.status(500).json({
      error: 'Search failed',
      message: error.message,
    });
  }
});

// News verification endpoint
app.post('/api/verify-news', searchLimiter, async (req, res) => {
  try {
    const { content, sourceDomain } = req.body;

    if (!content) {
      return res.status(400).json({
        error: 'Missing content',
        message: 'News content is required',
      });
    }

    if (!SERP_API_KEY) {
      // Return simulation data if API not configured
      return res.json({
        success: true,
        isSimulated: true,
        isVerified: false,
        verificationStatus: 'UNVERIFIED',
        credibleSourceCount: 0,
        matchingSourceCount: 0,
        supportingUrls: [],
        summary: 'Limited verification available (simulation mode)',
      });
    }

    // Build search query from content
    const query = buildSearchQuery(content);

    // Call SerpAPI
    const response = await axios.get('https://serpapi.com/search', {
      params: {
        q: query,
        api_key: SERP_API_KEY,
        num: 10,
        engine: 'google',
      },
      timeout: 10000,
    });

    // Analyze results
    const results = response.data.organic_results || [];
    const verification = analyzeVerification(results, content, sourceDomain);

    res.json({
      success: true,
      isSimulated: false,
      ...verification,
      searchQuery: query,
      processedAt: new Date().toISOString(),
    });

  } catch (error) {
    console.error('Verification error:', error.message);
    res.status(500).json({
      error: 'Verification failed',
      message: error.message,
    });
  }
});

// AI Analysis proxy endpoint with multi-provider fallback
app.post('/api/ai/analyze', async (req, res) => {
  try {
    const { content, webResults, prompt } = req.body;

    if (!content) {
      return res.status(400).json({
        error: 'Missing content',
        message: 'News content is required',
      });
    }

    // Try multiple AI providers in order
    const result = await analyzeWithFallback(content, webResults, prompt);
    
    res.json({
      success: true,
      ...result,
      processedAt: new Date().toISOString(),
    });

  } catch (error) {
    console.error('AI analysis error:', error.message);
    res.status(500).json({
      error: 'AI analysis failed',
      message: error.message,
    });
  }
});

// Multi-provider AI analysis with fallback
async function analyzeWithFallback(content, webResults, customPrompt) {
  const prompt = customPrompt || buildAnalysisPrompt(content, webResults);
  
  // Try providers in order: OpenRouter -> Groq -> Mistral -> Local
  const providers = [
    { name: 'openrouter', fn: () => analyzeWithOpenRouter(prompt) },
    { name: 'groq', fn: () => analyzeWithGroq(prompt) },
    { name: 'mistral', fn: () => analyzeWithMistral(prompt) },
  ].filter(p => isProviderConfigured(p.name));

  for (const provider of providers) {
    try {
      console.log(`Trying AI provider: ${provider.name}`);
      const result = await provider.fn();
      console.log(`✅ Success with ${provider.name}`);
      return { ...result, provider: provider.name };
    } catch (error) {
      console.log(`❌ ${provider.name} failed: ${error.message}`);
      continue;
    }
  }

  // Fallback to local simulation
  console.log('⚠️ All AI providers failed, using local simulation');
  return analyzeLocal(content, webResults);
}

function isProviderConfigured(name) {
  switch (name) {
    case 'openrouter': return !!OPENROUTER_API_KEY;
    case 'groq': return !!GROQ_API_KEY;
    case 'mistral': return !!MISTRAL_API_KEY;
    default: return false;
  }
}

// OpenRouter API (multi-model access including free models)
async function analyzeWithOpenRouter(prompt) {
  const response = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
    model: 'mistralai/mistral-7b-instruct:free', // Free tier
    messages: [
      {
        role: 'system',
        content: 'You are a news verification AI. Analyze news credibility and return JSON with: credibilityScore (0-100), verificationTier (VERIFIED/LIKELY_TRUE/UNVERIFIED/SUSPICIOUS), aiSummary, redFlags (array), trustIndicators (array).'
      },
      { role: 'user', content: prompt }
    ],
    temperature: 0.1,
    max_tokens: 400,
  }, {
    headers: {
      'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://aegis-intelligence.app',
      'X-Title': 'AEGIS Intelligence',
    },
    timeout: 15000,
  });

  return parseAIResponse(response.data.choices[0].message.content);
}

// Groq API (fast inference, free tier available)
async function analyzeWithGroq(prompt) {
  const response = await axios.post('https://api.groq.com/openai/v1/chat/completions', {
    model: 'llama-3.1-8b-instant', // Fast and cost-effective
    messages: [
      {
        role: 'system',
        content: 'You are a news verification AI. Analyze news credibility and return JSON with: credibilityScore (0-100), verificationTier (VERIFIED/LIKELY_TRUE/UNVERIFIED/SUSPICIOUS), aiSummary, redFlags (array), trustIndicators (array).'
      },
      { role: 'user', content: prompt }
    ],
    temperature: 0.1,
    max_tokens: 400,
  }, {
    headers: {
      'Authorization': `Bearer ${GROQ_API_KEY}`,
      'Content-Type': 'application/json',
    },
    timeout: 10000,
  });

  return parseAIResponse(response.data.choices[0].message.content);
}

// Mistral API
async function analyzeWithMistral(prompt) {
  const response = await axios.post('https://api.mistral.ai/v1/chat/completions', {
    model: 'mistral-small-latest',
    messages: [
      {
        role: 'system',
        content: 'You are a news verification AI. Analyze news credibility and return JSON.'
      },
      { role: 'user', content: prompt }
    ],
    temperature: 0.1,
    max_tokens: 400,
    response_format: { type: 'json_object' },
  }, {
    headers: {
      'Authorization': `Bearer ${MISTRAL_API_KEY}`,
      'Content-Type': 'application/json',
    },
    timeout: 15000,
  });

  const content = response.data.choices[0].message.content;
  return parseAIResponse(content);
}

// Local rule-based analysis (fallback)
function analyzeLocal(content, webResults) {
  // Simple heuristic analysis
  const reputableKeywords = ['official', 'confirmed', 'announced', 'reported'];
  const suspiciousKeywords = ['rumor', 'unverified', 'allegedly', 'claimed', 'sources say'];
  
  const contentLower = content.toLowerCase();
  let score = 50;
  const redFlags = [];
  const trustIndicators = [];

  // Check for reputable indicators
  reputableKeywords.forEach(kw => {
    if (contentLower.includes(kw)) {
      score += 5;
      trustIndicators.push(`Contains "${kw}"`);
    }
  });

  // Check for suspicious indicators
  suspiciousKeywords.forEach(kw => {
    if (contentLower.includes(kw)) {
      score -= 10;
      redFlags.push(`Contains "${kw}"`);
    }
  });

  // Web results boost
  if (webResults?.credibleSourceCount > 0) {
    score += webResults.credibleSourceCount * 5;
    trustIndicators.push(`Found ${webResults.credibleSourceCount} credible sources`);
  }

  score = Math.max(0, Math.min(100, score));

  let verificationTier;
  if (score >= 80) verificationTier = 'VERIFIED';
  else if (score >= 60) verificationTier = 'LIKELY_TRUE';
  else if (score >= 40) verificationTier = 'UNVERIFIED';
  else verificationTier = 'SUSPICIOUS';

  return {
    credibilityScore: score,
    verificationTier,
    aiSummary: `Local analysis: ${trustIndicators.length} trust indicators, ${redFlags.length} red flags`,
    redFlags,
    trustIndicators,
    provider: 'local',
  };
}

function buildAnalysisPrompt(content, webResults) {
  let prompt = `Analyze this news item:\n\nContent: ${content}\n\n`;
  
  if (webResults) {
    prompt += `Web Verification Data:\n`;
    prompt += `- Credible sources found: ${webResults.credibleSourceCount || 0}\n`;
    prompt += `- Matching sources: ${webResults.matchingSourceCount || 0}\n`;
    prompt += `- Verification status: ${webResults.verificationStatus || 'Unknown'}\n\n`;
  }
  
  prompt += `Return JSON with:\n`;
  prompt += `- credibilityScore: integer 0-100\n`;
  prompt += `- verificationTier: one of VERIFIED, LIKELY_TRUE, UNVERIFIED, SUSPICIOUS\n`;
  prompt += `- aiSummary: brief 1-2 sentence analysis\n`;
  prompt += `- redFlags: array of concerning indicators\n`;
  prompt += `- trustIndicators: array of credibility signals\n`;
  
  return prompt;
}

function parseAIResponse(content) {
  try {
    // Try to parse as JSON
    const parsed = JSON.parse(content);
    return {
      credibilityScore: Math.max(0, Math.min(100, parsed.credibilityScore || 50)),
      verificationTier: parsed.verificationTier || 'UNVERIFIED',
      aiSummary: parsed.aiSummary || 'Analysis completed',
      redFlags: Array.isArray(parsed.redFlags) ? parsed.redFlags : [],
      trustIndicators: Array.isArray(parsed.trustIndicators) ? parsed.trustIndicators : [],
    };
  } catch (e) {
    // Fallback: extract info from text
    const score = content.match(/(\d+)/)?.[0] || 50;
    return {
      credibilityScore: parseInt(score),
      verificationTier: content.includes('VERIFIED') ? 'VERIFIED' : 
                       content.includes('LIKELY_TRUE') ? 'LIKELY_TRUE' :
                       content.includes('SUSPICIOUS') ? 'SUSPICIOUS' : 'UNVERIFIED',
      aiSummary: content.substring(0, 200),
      redFlags: [],
      trustIndicators: [],
    };
  }
}

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: NODE_ENV === 'development' ? err.message : 'Something went wrong',
  });
});

// Risk Map API endpoints
app.get('/api/v1/map/countries', async (req, res) => {
  try {
    const countries = ['USA', 'CHN', 'RUS', 'IRN', 'ISR', 'UKR', 'TWN'];
    const results = await Promise.all(
      countries.map(async (country) => {
        // Mock risk calculation (gerçek implementasyon ACLED/GDELT ile yapılacak)
        const riskScore = Math.random() * 100;
        let riskLevel;
        if (riskScore >= 80) riskLevel = 'CRITICAL';
        else if (riskScore >= 60) riskLevel = 'HIGH';
        else if (riskScore >= 40) riskLevel = 'ELEVATED';
        else if (riskScore >= 20) riskLevel = 'GUARDED';
        else riskLevel = 'LOW';
        
        return {
          country,
          risk_score: Math.round(riskScore * 10) / 10,
          risk_level: riskLevel,
          breakdown: { active_conflicts: riskScore * 0.25 },
          timestamp: new Date().toISOString(),
        };
      })
    );
    
    res.json({
      success: true,
      data: results,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/v1/map/country/:iso3', async (req, res) => {
  try {
    const { iso3 } = req.params;
    const riskScore = Math.random() * 100;
    let riskLevel;
    if (riskScore >= 80) riskLevel = 'CRITICAL';
    else if (riskScore >= 60) riskLevel = 'HIGH';
    else if (riskScore >= 40) riskLevel = 'ELEVATED';
    else if (riskScore >= 20) riskLevel = 'GUARDED';
    else riskLevel = 'LOW';
    
    const result = {
      country: iso3.toUpperCase(),
      risk_score: Math.round(riskScore * 10) / 10,
      risk_level: riskLevel,
      breakdown: { active_conflicts: riskScore * 0.25 },
      timestamp: new Date().toISOString(),
    };
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/v1/map/events/active', async (req, res) => {
  try {
    const activeEvents = [
      {
        id: 'evt_001',
        title: 'Orta Doğu Askeri Gerilim',
        latitude: 32.4279,
        longitude: 53.6903,
        severity: 'CRITICAL',
        importance: 85,
        countries: ['IRN', 'ISR'],
        timestamp: new Date().toISOString()
      },
      {
        id: 'evt_002', 
        title: 'Tayvan Boğazı Artan Gerilim',
        latitude: 25.0308,
        longitude: 121.5457,
        severity: 'HIGH',
        importance: 72,
        countries: ['TWN', 'CHN'],
        timestamp: new Date().toISOString()
      }
    ];
    
    res.json({
      success: true,
      data: activeEvents
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/v1/map/events', async (req, res) => {
  try {
    const { lat, lng, radius = 50 } = req.query;
    
    const events = [
      {
        id: 'evt_001',
        title: 'Orta Doğu Askeri Gerilim',
        latitude: parseFloat(lat),
        longitude: parseFloat(lng),
        severity: 'CRITICAL',
        importance: 85,
        distance: 15
      }
    ].filter(event => {
      const eventLat = event.latitude;
      const eventLng = event.longitude;
      const distance = Math.sqrt(
        Math.pow(parseFloat(lat) - eventLat, 2) + 
        Math.pow(parseFloat(lng) - eventLng, 2)
      ) * 111;
      return distance <= parseFloat(radius);
    });
    
    res.json({
      success: true,
      data: events,
      center: { lat: parseFloat(lat), lng: parseFloat(lng) },
      radius: parseFloat(radius)
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/v1/map/heatmap', async (req, res) => {
  try {
    const { timeframe = '24h' } = req.query;
    
    const heatmapData = {
      type: 'heatmap',
      timeframe,
      data: [
        { lat: 32.4, lng: 53.7, intensity: 0.9 }, // İran
        { lat: 31.8, lng: 35.7, intensity: 0.8 }, // İsrail
        { lat: 25.0, lng: 121.5, intensity: 0.7 }, // Tayvan
        { lat: 39.9, lng: 116.4, intensity: 0.6 }, // Pekin
      ]
    };
    
    res.json({
      success: true,
      data: heatmapData
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/v1/map/connections', async (req, res) => {
  try {
    const connections = [
      {
        source: { lat: 32.4, lng: 53.7, risk: 'CRITICAL' },
        target: { lat: 31.8, lng: 35.7, risk: 'HIGH' },
        strength: 0.8
      }
    ];
    
    res.json({
      success: true,
      data: connections
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not found',
    message: `Endpoint ${req.method} ${req.path} not found`,
  });
});

// Helper functions
function extractDomain(url) {
  try {
    const urlObj = new URL(url);
    return urlObj.hostname.replace(/^www\./, '');
  } catch {
    return 'unknown';
  }
}

function buildSearchQuery(content) {
  // Extract key terms (first 8 significant words)
  return content
    .replace(/[^\w\s]/g, '')
    .split(' ')
    .filter(w => w.length > 3)
    .slice(0, 8)
    .join(' ');
}

function analyzeVerification(results, originalContent, originalSource) {
  const reputableSources = [
    'reuters.com', 'bloomberg.com', 'apnews.com', 'afp.com',
    'bbc.com', 'cnn.com', 'ft.com', 'wsj.com', 'nytimes.com',
    'economist.com', 'forbes.com', 'cnbc.com', 'aljazeera.com',
    'theguardian.com', 'washingtonpost.com', 'time.com',
  ];

  let credibleSourceCount = 0;
  let matchingSourceCount = 0;
  const supportingUrls = [];
  const contentKeywords = originalContent.toLowerCase().split(' ');

  for (const result of results) {
    const source = extractDomain(result.link);
    const isReputable = reputableSources.some(s => source.includes(s));

    if (isReputable) {
      credibleSourceCount++;
      
      // Check content similarity
      const snippetWords = (result.snippet || '').toLowerCase().split(' ');
      const commonWords = contentKeywords.filter(w => snippetWords.includes(w));
      const similarity = commonWords.length / contentKeywords.length;

      if (similarity > 0.3) {
        matchingSourceCount++;
        supportingUrls.push(result.link);
      }
    }
  }

  let verificationStatus;
  let credibilityBoost;

  if (credibleSourceCount >= 3 && matchingSourceCount >= 2) {
    verificationStatus = 'VERIFIED';
    credibilityBoost = 25;
  } else if (credibleSourceCount >= 2 && matchingSourceCount >= 1) {
    verificationStatus = 'LIKELY_TRUE';
    credibilityBoost = 15;
  } else if (credibleSourceCount >= 1) {
    verificationStatus = 'UNVERIFIED';
    credibilityBoost = 5;
  } else {
    verificationStatus = 'SINGLE_SOURCE';
    credibilityBoost = 0;
  }

  return {
    isVerified: verificationStatus === 'VERIFIED',
    verificationStatus,
    credibleSourceCount,
    matchingSourceCount,
    supportingUrls: supportingUrls.slice(0, 3),
    credibilityBoost,
    summary: credibleSourceCount > 0 
      ? `Found ${credibleSourceCount} credible source(s)`
      : 'Limited verification available',
  };
}

// Start server
app.listen(PORT, () => {
  console.log(`
╔══════════════════════════════════════════════════╗
║        AEGIS Intelligence Backend API              ║
║              Production Ready                      ║
╠══════════════════════════════════════════════════╣
║  Port:        ${PORT.toString().padEnd(37)}║
║  Environment: ${NODE_ENV.padEnd(37)}║
║  SerpAPI:     ${(SERP_API_KEY ? '✅ Configured' : '❌ Not configured').padEnd(37)}║
║  Mistral AI:  ${(MISTRAL_API_KEY ? '✅ Configured' : '❌ Not configured').padEnd(37)}║
╚══════════════════════════════════════════════════╝
  `);
});

module.exports = app;
