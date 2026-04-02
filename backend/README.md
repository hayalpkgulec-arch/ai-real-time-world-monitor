# AEGIS Intelligence Backend

Production-ready Node.js/Express backend for AEGIS Intelligence mobile app.

## Features

- 🔍 **SerpAPI Proxy** - Web search with rate limiting
- 🔒 **Security** - Helmet, CORS, Rate limiting
- 📊 **Analytics** - Request logging with Morgan
- 🚀 **Performance** - Compression enabled
- 🛡️ **Error Handling** - Comprehensive error responses

## Quick Start

```bash
# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env with your API keys

# Start development server
npm run dev

# Or start production server
npm start
```

## API Endpoints

### Health Check
```
GET /health
```

### API Status
```
GET /api/status
```

### Web Search
```
GET /api/search?q=your+search+query&num=10
```

### News Verification
```
POST /api/verify-news
Content-Type: application/json

{
  "content": "News article content...",
  "sourceDomain": "reuters.com"
}
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SERP_API_KEY` | Yes | SerpAPI key for web search |
| `MISTRAL_API_KEY` | No | Mistral AI key (future use) |
| `PORT` | No | Server port (default: 3000) |
| `ALLOWED_ORIGINS` | No | CORS origins (default: *) |
| `NODE_ENV` | No | development/production |

## Deployment

### Option 1: Railway (Recommended)
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### Option 2: Render
1. Connect GitHub repo to Render
2. Set environment variables
3. Deploy automatically

### Option 3: Heroku
```bash
heroku create aegis-backend
heroku config:set SERP_API_KEY=your_key
heroku config:set NODE_ENV=production
git push heroku main
```

### Option 4: Docker
```bash
docker build -t aegis-backend .
docker run -p 3000:3000 --env-file .env aegis-backend
```

## Rate Limits

- General API: 60 requests/minute
- Search endpoints: 20 requests/minute

## Mobile App Integration

Update your Flutter app to use the backend:

```dart
// Instead of calling SerpAPI directly:
// Call your backend:
final response = await http.get(
  Uri.parse('https://your-backend.com/api/search?q=$query'),
);
```

## Security

- Helmet.js for security headers
- CORS configured for specific origins
- Rate limiting prevents abuse
- API keys never exposed to client

## License

MIT
