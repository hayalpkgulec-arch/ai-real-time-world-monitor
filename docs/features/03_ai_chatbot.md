# 🤖 AI Geopolitik Chatbot — Teknik Şartname

> RAG (Retrieval Augmented Generation) tabanlı doğal dil sorgu arayüzü.
> "Petrol neden yükseldi?" gibi sorulara gerçek zamanlı veriye dayalı yanıt verir.

---

## 🎯 Vizyon

Kullanıcı ChatGPT tarzında soru sorar, sistem **gerçek zamanlı olay verilerini** kullanarak
bağlamsal, güncel ve kaynaklı yanıtlar üretir. Genel bir LLM'den farkı:
**her yanıt o anki gerçek verilere dayanır**.

---

## 🏗️ RAG Mimarisi

```
┌─────────────────────────────────────────────────────┐
│                  KULLANICI SORGUSU                   │
│         "Petrol neden yükseldi?"                     │
└──────────────────────┬──────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│              QUERY PROCESSING                        │
│                                                      │
│  1. Intent Classification (ne soruluyor?)            │
│  2. Entity Extraction (petrol, yükseliş)             │
│  3. Time Detection (bugün / son 7 gün?)              │
│  4. Query Expansion (oil, crude, brent, wti)         │
└──────────────────────┬──────────────────────────────┘
                       ▼
         ┌─────────────┴─────────────┐
         ▼                           ▼
┌─────────────────┐        ┌─────────────────┐
│  VECTOR SEARCH  │        │  STRUCTURED     │
│  (Semantic)     │        │  QUERY          │
│                 │        │                 │
│ Qdrant/Milvus   │        │ Events DB       │
│ → İlişkili      │        │ → Petrol fiyat  │
│   haberler,     │        │   verisi,       │
│   olaylar       │        │   market data   │
└────────┬────────┘        └────────┬────────┘
         └─────────────┬────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│              CONTEXT BUILDER                         │
│                                                      │
│  Retrieved chunks + Market data + Event timeline     │
│  → Prompt template'e yerleştir                       │
└──────────────────────┬──────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│              LLM GENERATION                          │
│                                                      │
│  Mistral 7B / LLaMA 3 / Qwen 2.5                   │
│  → Bağlamsal, kaynaklı yanıt üret                   │
└──────────────────────┬──────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│              RESPONSE FORMATTING                     │
│                                                      │
│  - Özet yanıt                                        │
│  - Kaynak linkleri                                   │
│  - İlişkili olaylar                                  │
│  - Piyasa grafikleri                                 │
│  - Takip soruları                                    │
└─────────────────────────────────────────────────────┘
```

---

## 💬 Örnek Sorgular & Yanıtlar

### Sorgu 1: Piyasa analizi
```
Kullanıcı: "Petrol neden yükseldi?"

AI Yanıt:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛢️ Petrol Fiyat Analizi

Brent ham petrol son 24 saatte %4.2 yükselerek 
$87.30'a ulaştı. Bunun 3 ana nedeni:

1. 🔴 Orta Doğu Gerilimi (Etki: %60)
   İran-İsrail arasındaki artan gerilim,
   Hürmüz Boğazı'ndan geçen tanker trafiğinde
   risk algısını artırdı.
   📰 Reuters, 2 saat önce

2. ⚡ OPEC+ Üretim Kısıtı (Etki: %25)
   Suudi Arabistan gönüllü kesinti süresini
   uzattığını duyurdu.
   📰 Bloomberg, 6 saat önce

3. 📊 ABD Stok Verisi (Etki: %15)
   EIA ham petrol stokları beklentinin üzerinde
   -4.2M varil azaldı.
   📰 EIA, dün

📈 AI Tahmini: Gerilim sürdüğü takdirde
$90-95 aralığına yükseliş olasılığı: %62

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 Kaynaklar: Reuters, Bloomberg, EIA
❓ Takip soruları:
  • "Bu portföyümü nasıl etkiler?"
  • "Benzer gerilimler geçmişte ne yaptı?"
  • "Altın da etkilenir mi?"
```

### Sorgu 2: Bölge analizi
```
Kullanıcı: "Tayvan Boğazı'nda son durum ne?"

AI Yanıt:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌏 Tayvan Boğazı Durumu

Risk Seviyesi: 🟡 ELEVATED (Skor: 58/100)

Son 7 günde tespit edilen olaylar:

📅 1 Nisan — Çin, boğazda büyük çaplı deniz 
tatbikatı başlattı (12 savaş gemisi)
📅 31 Mart — ABD, USS Ronald Reagan uçak 
gemisini bölgeye konuşlandırdı
📅 29 Mart — Tayvan, hava savunma tatbikatı 
yaptı

📊 AI Değerlendirme:
Durum, mevcut haliyle "rutin gerilim" seviyesinde.
Ancak tatbikat ölçeğinin büyüklüğü dikkat çekici.
Tırmanma olasılığı (7 gün): %18

💹 Potansiyel Piyasa Etkisi:
- TSMC: ↓ -2-5% (çip tedarik riski)
- Yarı iletken ETF: ↓ -1-3%
- Yuan/USD: ↓ -0.5-1%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Sorgu 3: Portföy odaklı
```
Kullanıcı: "Portföyümdeki riskler neler?"

AI Yanıt:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💼 Portföy Risk Analizi

Portföyünüzdeki varlıklar analiz edildi:

🔴 Yüksek Risk:
  • XLE (Enerji ETF) — Orta Doğu gerilimi 
    devam ederse volatilite artabilir
  • TSM (TSMC) — Tayvan gerilimi riski

🟡 Orta Risk:
  • AAPL — Çin pazarındaki düzenleyici 
    baskılar sürebilir

🟢 Düşük Risk:
  • GLD (Altın ETF) — Güvenli liman talebi 
    artışından faydalanabilir
  • BTC — Makro belirsizlik dijital varlıklara 
    ilgiyi artırıyor

📊 Genel Portföy Risk Skoru: 45/100 (Orta)
💡 Öneri: Enerji pozisyonlarında stop-loss 
   seviyelerini gözden geçirmeniz önerilir.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🧠 Query Processing Pipeline

```python
class QueryProcessor:
    """Kullanıcı sorgusunu analiz eder ve yapılandırır."""
    
    INTENT_TYPES = [
        'WHY_ANALYSIS',        # "Neden X oldu?"
        'WHAT_HAPPENED',       # "X'te ne oldu?"
        'MARKET_IMPACT',       # "X piyasaları nasıl etkiler?"
        'RISK_ASSESSMENT',     # "X riski nedir?"
        'PORTFOLIO_QUERY',     # "Portföyüm nasıl?"
        'COMPARISON',          # "A vs B"
        'PREDICTION',          # "X olacak mı?"
        'GENERAL_BRIEFING',    # "Bugün dünyada ne oldu?"
    ]
    
    def process(self, query: str, user_context: dict) -> dict:
        # 1. Intent classification
        intent = self._classify_intent(query)
        
        # 2. Entity extraction
        entities = self._extract_entities(query)
        # output: {'commodities': ['oil'], 'regions': [], 'events': ['surge']}
        
        # 3. Time frame detection
        timeframe = self._detect_timeframe(query)
        # output: {'start': '2026-04-01', 'end': '2026-04-02', 'label': 'today'}
        
        # 4. Expand query for better retrieval
        expanded_terms = self._expand_query(query, entities)
        # "petrol yükselmesi" → ["oil", "crude", "brent", "wti", "petroleum",
        #                         "price increase", "surge", "rally"]
        
        return {
            'original_query': query,
            'intent': intent,
            'entities': entities,
            'timeframe': timeframe,
            'expanded_terms': expanded_terms,
            'user_portfolio': user_context.get('portfolio', []),
            'user_watchlist': user_context.get('watchlist', []),
        }
```

---

## 🔍 Retrieval System

```python
class ContextRetriever:
    """Vektör DB + yapısal DB'den ilişkili bilgileri getirir."""
    
    def __init__(self):
        self.vector_db = QdrantClient(host="localhost", port=6333)
        self.events_db = EventsDatabase()
        self.market_db = MarketDatabase()
    
    def retrieve(self, processed_query: dict, top_k=10) -> dict:
        context = {}
        
        # 1. Semantik arama — ilişkili haberler ve olaylar
        query_embedding = self.embed(processed_query['original_query'])
        
        vector_results = self.vector_db.search(
            collection_name="news_articles",
            query_vector=query_embedding,
            query_filter=Filter(
                must=[
                    FieldCondition(
                        key="timestamp",
                        range=Range(
                            gte=processed_query['timeframe']['start'],
                            lte=processed_query['timeframe']['end'],
                        )
                    )
                ]
            ),
            limit=top_k,
        )
        context['related_articles'] = vector_results
        
        # 2. Yapısal veri — piyasa verileri
        if processed_query['intent'] in ('WHY_ANALYSIS', 'MARKET_IMPACT'):
            for commodity in processed_query['entities'].get('commodities', []):
                context[f'market_{commodity}'] = self.market_db.get_price_history(
                    commodity, days=7
                )
        
        # 3. Olay zaman çizelgesi
        for region in processed_query['entities'].get('regions', []):
            context[f'events_{region}'] = self.events_db.get_events(
                region=region,
                timeframe=processed_query['timeframe'],
                limit=20,
            )
        
        # 4. Portföy verileri (varsa)
        if processed_query['intent'] == 'PORTFOLIO_QUERY':
            portfolio = processed_query['user_portfolio']
            context['portfolio_data'] = self._get_portfolio_exposure(portfolio)
        
        return context
    
    def embed(self, text: str) -> list[float]:
        """Text → embedding vektörü (384/768 boyut)."""
        # sentence-transformers/all-MiniLM-L6-v2 veya multilingual equivalent
        return self.embedding_model.encode(text).tolist()
```

---

## 📝 Prompt Template

```python
SYSTEM_PROMPT = """Sen bir küresel istihbarat analisti ve finansal danışmansın.
Kullanıcının sorularını gerçek zamanlı veriler ve güncel olaylara dayanarak yanıtlarsın.

KURALLAR:
1. Her zaman kaynak belirt
2. Tahminlerde olasılık yüzdesi ver
3. Emin olmadığın konularda bunu açıkça belirt
4. Yanıtları yapılandırılmış formatta ver
5. Piyasa etkisi varsa somut rakamlar kullan
6. Kullanıcının portföy bilgisi varsa kişiselleştirilmiş analiz yap
7. Her yanıtın sonunda 2-3 takip sorusu öner

BUGÜNÜN TARİHİ: {current_date}
GÜNCEL RİSK ENDEKSİ: {global_risk_index}/100
"""

USER_PROMPT = """
SORU: {user_query}

BAĞLAM VERİLERİ:
---
İlişkili Haberler:
{related_articles}

Piyasa Verileri:
{market_data}

Aktif Olaylar:
{active_events}

Kullanıcı Portföyü:
{portfolio_data}
---

Yukarıdaki verilere dayanarak kullanıcının sorusunu yanıtla.
"""
```

---

## 💡 Önceden Tanımlı Hızlı Sorgular

```javascript
// Kullanıcıya sunulan hazır soru önerileri
const quickQueries = [
  {
    emoji: '🌍',
    text: 'Bugün dünyada ne oldu?',
    intent: 'GENERAL_BRIEFING',
  },
  {
    emoji: '🔴',
    text: 'En riskli bölge neresi?',
    intent: 'RISK_ASSESSMENT',
  },
  {
    emoji: '💼',
    text: 'Portföyüm risk altında mı?',
    intent: 'PORTFOLIO_QUERY',
  },
  {
    emoji: '🛢️',
    text: 'Petrol fiyatı nereye gider?',
    intent: 'PREDICTION',
  },
  {
    emoji: '📊',
    text: 'Haftalık risk özeti',
    intent: 'GENERAL_BRIEFING',
  },
  {
    emoji: '⚡',
    text: 'Son breaking event nedir?',
    intent: 'WHAT_HAPPENED',
  },
];
```

---

## 🔄 Streaming Yanıt Sistemi

```javascript
// === STREAMING CHAT RESPONSE ===
async function* streamChatResponse(query, userContext) {
  const ws = new WebSocket('wss://api.worldmonitor.app/ws/chat');
  
  ws.send(JSON.stringify({
    query: query,
    user_id: userContext.userId,
    portfolio: userContext.portfolio,
    stream: true,
  }));
  
  // Token token yanıt alımı (ChatGPT tarzı)
  for await (const message of ws) {
    const data = JSON.parse(message);
    
    switch (data.type) {
      case 'token':
        yield { type: 'text', content: data.token };
        break;
      case 'source':
        yield { type: 'source', source: data.source };
        break;
      case 'chart':
        yield { type: 'chart', chartData: data.chartData };
        break;
      case 'event_card':
        yield { type: 'event', event: data.event };
        break;
      case 'done':
        yield { type: 'complete', suggestions: data.followUpQuestions };
        return;
    }
  }
}
```

---

## 📐 Backend API

```
POST /api/v1/chat/query
     Body: { query, context, stream: false }
     → Tam yanıt (tek seferde)

WS   /ws/chat
     → Streaming yanıt (token-by-token)

GET  /api/v1/chat/history?limit=50
     → Sohbet geçmişi

GET  /api/v1/chat/suggestions
     → Günlük önerilen sorgular

POST /api/v1/chat/feedback
     Body: { message_id, rating, comment }
     → Yanıt kalitesi geri bildirimi
```

---

## 📋 Geliştirme Fazları

| Faz | Süre | Çıktı |
|-----|------|-------|
| **Faz 1** | 2 hafta | Temel chat UI + basit keyword-based retreival |
| **Faz 2** | 2 hafta | Qdrant vektör DB + embedding pipeline |
| **Faz 3** | 2 hafta | LLM entegrasyonu (Mistral/LLaMA) + RAG pipeline |
| **Faz 4** | 1 hafta | Streaming yanıt + gömülü chart/kart |
| **Faz 5** | 1 hafta | Portföy entegrasyonu + kişiselleştirme |
| **Faz 6** | 1 hafta | Geri bildirim sistemi + fine-tuning data toplama |
