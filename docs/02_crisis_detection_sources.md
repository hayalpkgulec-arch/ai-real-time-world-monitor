# 🔴 Gerçek Zamanlı Savaş / Kriz Tespiti Veri Kaynakları

> Bu belge, AI Real-Time World Monitor'ün kriz/savaş tespiti modülü için
> kullanılacak tüm veri kaynaklarını, API'leri ve OSINT tekniklerini içerir.

---

## 🏗️ Kriz Tespit Mimarisi

```
┌─────────────────────────────────────────────────┐
│              CRISIS DETECTION ENGINE             │
├────────┬────────┬────────┬────────┬──────────────┤
│ OSINT  │ Resmi  │ Piyasa │ Sosyal │ Sensör/      │
│ Veri   │ Kurum  │ Sinyal │ Medya  │ Uydu Verisi  │
│ Katmanı│ Katmanı│ Katmanı│ Katmanı│ Katmanı      │
├────────┴────────┴────────┴────────┴──────────────┤
│          AI Fusion & Correlation Engine           │
├──────────────────────────────────────────────────┤
│          Alert & Notification System              │
└──────────────────────────────────────────────────┘
```

---

## 📡 KATMAN 1: OSINT (Açık Kaynak İstihbarat) Veri Kaynakları

### 1.1 Çatışma & Silahlı Şiddet Veritabanları

| Kaynak | Açıklama | Veri Tipi | Maliyet | Güncelleme |
|--------|----------|-----------|---------|------------|
| **ACLED** (Armed Conflict Location & Event Data) | Küresel çatışma olayları, protestolar, şiddet | API + CSV | Ücretsiz (akademik) | Haftalık |
| **UCDP** (Uppsala Conflict Data Program) | Organize şiddet olayları veritabanı | API + CSV | Ücretsiz | Aylık |
| **GTD** (Global Terrorism Database) | Terör saldırıları veritabanı | CSV download | Ücretsiz | Yıllık |
| **GDELT Project** | Küresel olaylar, ilişkiler, duygular | BigQuery API | Ücretsiz | 15 dakika |
| **ICB** (International Crisis Behavior) | Devletler arası krizler | Dataset | Ücretsiz | Periyodik |
| **PITF** (Political Instability Task Force) | Siyasi istikrarsızlık göstergeleri | Rapor | Ücretsiz | Periyodik |

### 1.2 GDELT Detaylı Kullanım
```
GDELT API Endpoints:
- GKG (Global Knowledge Graph): Her 15 dk güncellenen olay grafiği
- Event Database: Actor-event-actor üçlüleri
- DOC API: Makale düzeyinde analiz
- TV API: TV yayınlarından kriz tespiti

Örnek sorgu:
GET https://api.gdelt.org/api/v2/doc/doc?query=conflict+military&mode=ArtList&maxrecords=250&format=json

Kriz tespiti için GDELT skorları:
- GoldsteinScale < -7 → Yüksek gerilim olayı
- AvgTone < -5 → Negatif tonlu küresel olay
- NumArticles > 100 (15dk içinde) → Viral olay
```

### 1.3 ACLED Detaylı Kullanım
```
ACLED API Endpoint:
GET https://api.acleddata.com/acled/read?key={API_KEY}&email={EMAIL}
    &event_date={DATE}&event_date_where=BETWEEN
    &fields=event_id_cnty,event_date,event_type,sub_event_type,
            actor1,actor2,country,admin1,location,latitude,longitude,
            fatalities,notes

Olay Tipleri:
- Battles
- Violence against civilians
- Explosions/Remote violence
- Riots
- Protests
- Strategic developments
```

---

## 🏛️ KATMAN 2: Resmi Kurum & Uluslararası Organizasyon Verileri

### 2.1 BM & Uluslararası Organizasyonlar

| Kaynak | Veri Tipi | API/Feed | Güncelleme |
|--------|-----------|----------|------------|
| **UN ReliefWeb** | Afet, insani kriz raporları | REST API | Gerçek zamanlı |
| **UN OCHA** | İnsani yardım koordinasyonu | API | Günlük |
| **UNHCR** | Mülteci akışları, yerinden edilme | API | Haftalık |
| **WHO DONS** | Hastalık salgınları | RSS + API | Gerçek zamanlı |
| **UNSC Resolutions** | BM Güvenlik Konseyi kararları | RSS | Olay bazlı |
| **IAEA** | Nükleer olay raporları | RSS | Olay bazlı |

### 2.2 ReliefWeb API Kullanımı
```
Base URL: https://api.reliefweb.int/v1

Endpoints:
- /reports → Kriz raporları
- /disasters → Aktif afetler
- /countries → Ülke bazlı kriz durumu

Örnek:
GET /v1/reports?appname=worldmonitor
    &filter[field]=primary_country.iso3
    &filter[value]=SYR
    &filter[operator]=AND
    &filter[conditions][0][field]=disaster_type.name
    &filter[conditions][0][value]=Conflict
    &sort[]=date:desc
    &limit=50
```

### 2.3 Devlet/Hükümet Kaynakları

| Kaynak | Ülke | Veri |
|--------|------|------|
| US State Dept Travel Advisories | ABD | Risk seviyeleri, çatışma uyarıları |
| UK FCDO Travel Advice | İngiltere | Ülke bazlı güvenlik değerlendirmesi |
| EU ECHO Daily Map | AB | Günlük kriz haritası |
| FEMA Alerts | ABD | Acil durum uyarıları |
| NWS (National Weather Service) | ABD | Doğal afet uyarıları |
| USGS Earthquake API | Global | Deprem verileri (gerçek zamanlı) |
| NOAA Storm Events | Global | Fırtına ve hava olayları |
| FIRMS (NASA Fire Info) | Global | Aktif yangın tespiti (uydu) |

### 2.4 USGS Deprem API
```
Endpoint: https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/
- significant_hour.geojson → Son 1 saat önemli depremler
- 4.5_day.geojson → Son 24 saat M4.5+ depremler
- all_week.geojson → Son 7 gün tüm depremler

Kriz tetikleyici: Magnitude >= 6.0 veya tsunami uyarısı
```

---

## 💹 KATMAN 3: Piyasa Sinyal Kaynakları (Kriz İndikatörleri)

### 3.1 Kriz-Duyarlı Piyasa Göstergeleri

| Gösterge | Kriz Sinyali | Kaynak API |
|----------|-------------|-----------|
| **VIX (Korku Endeksi)** | > 30 = yüksek korku | Yahoo Finance, Alpha Vantage |
| **CDS Spreads** | Ülke temerrüt riski artışı | Investing.com |
| **Petrol Fiyatı** | Ani %5+ artış = jeopolitik kriz | Yahoo Finance |
| **Altın Fiyatı** | Ani %3+ artış = güvenli liman talebi | Yahoo Finance |
| **USD/TRY, EUR gibi çaprazlar** | Ani %2+ hareket = finansal stres | Exchange Rates API |
| **10Y US Treasury Yield** | Ani düşüş = risk-off | FRED API |
| **Bitcoin Volatility** | Ani %10+ hareket = makro belirsizlik | CoinGecko |

### 3.2 Ücretsiz Piyasa API'leri
```
Alpha Vantage (ücretsiz tier):
GET https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=CL=F&apikey={KEY}

Yahoo Finance (yfinance Python kütüphanesi):
- Petrol (CL=F), Altın (GC=F), VIX (^VIX)
- S&P 500 (^GSPC), NASDAQ (^IXIC)

CoinGecko API (ücretsiz):
GET https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd&include_24hr_change=true

FRED API (Fed ekonomik verileri):
GET https://api.stlouisfed.org/fred/series/observations?series_id=VIXCLS&api_key={KEY}

ExchangeRate API:
GET https://open.er-api.com/v6/latest/USD
```

### 3.3 Kriz Sinyal Algoritması
```python
def calculate_crisis_market_signal(data):
    signals = {
        'vix_spike': data['vix'] > 30,
        'oil_surge': data['oil_change_pct'] > 5,
        'gold_surge': data['gold_change_pct'] > 3,
        'treasury_flight': data['us10y_change'] < -0.15,
        'crypto_crash': abs(data['btc_change_pct']) > 10,
        'dollar_surge': data['dxy_change_pct'] > 1.5,
    }
    
    crisis_score = sum(signals.values()) / len(signals) * 100
    
    if crisis_score >= 60:
        return 'CRITICAL', crisis_score
    elif crisis_score >= 40:
        return 'HIGH', crisis_score
    elif crisis_score >= 20:
        return 'ELEVATED', crisis_score
    else:
        return 'NORMAL', crisis_score
```

---

## 🐦 KATMAN 4: Sosyal Medya & Alternatif Sinyaller

### 4.1 Sosyal Medya İzleme

| Platform | Yöntem | Kriz Sinyali |
|----------|--------|-------------|
| **X (Twitter)** | Keyword + geo tracking | Ani hacim artışı belirli anahtar kelimelerle |
| **Telegram** | Kanal izleme (savaş bölgeleri) | Çatışma bölgelerinden ilk bilgiler |
| **Reddit** | Subreddit izleme | r/worldnews, r/geopolitics trending |
| **YouTube** | Canlı yayın izleme | Çatışma bölgelerindeki canlı yayınlar |

### 4.2 X/Twitter Kriz Anahtar Kelimeleri
```
Savaş/Çatışma:
"breaking" + ("war", "attack", "missile", "bombing", "explosion", "troops")
"military strike", "air raid", "ceasefire broken", "invasion"

Doğal Afet:
"earthquake" + ("magnitude", "tsunami warning", "collapsed")
"hurricane" + ("category", "landfall", "evacuation")
"wildfire" + ("evacuate", "state of emergency")

Ekonomik Kriz:
"bank run", "default", "currency crash", "market crash"
"emergency rate", "bailout", "sanctions"

Sağlık Krizi:
"outbreak", "pandemic", "quarantine", "WHO emergency"
```

### 4.3 Telegram OSINT Kanalları (Çatışma İzleme)
```
Jeopolitik:
- War Monitor, Intel Slava Z, Rybar (dikkatli kullanım — bias kontrolü gerekli)
- OSINTdefender, GeoConfirmed, Conflict News

NOT: Telegram kaynakları doğrulama katmanından geçirilmeli.
Cross-reference zorunlu. Tek kaynak güvenilmez.
```

---

## 🛰️ KATMAN 5: Uydu & Sensör Verileri

### 5.1 Ücretsiz Uydu Veri Kaynakları

| Kaynak | Veri | Kullanım |
|--------|------|----------|
| **NASA FIRMS** | Aktif yangın noktaları | Savaş bölgelerinde patlama/yangın tespiti |
| **Sentinel Hub** | Optik uydu görüntüleri | Altyapı hasarı tespiti |
| **NASA Earthdata** | Çevresel veri | Doğal afet izleme |
| **Copernicus EMS** | Acil durum haritaları | Sel, deprem, yangın haritaları |
| **NOAA GOES** | Hava durumu uydu verileri | Fırtına ve afet izleme |

### 5.2 NASA FIRMS API
```
Aktif yangın verileri (NRT - Near Real Time):
GET https://firms.modaps.eosdis.nasa.gov/api/area/csv/{MAP_KEY}/VIIRS_SNPP_NRT/{country}/1

Ücretsiz MAP_KEY ile günlük 100 istek.
Savaş bölgelerinde ani yangın artışı → çatışma sinyali
```

---

## 🧠 KRİZ TESPİT ALGORİTMASI

### Çoklu Sinyal Füzyonu
```python
class CrisisDetector:
    def __init__(self):
        self.weights = {
            'osint_conflict_data': 0.25,    # ACLED, GDELT
            'official_alerts': 0.20,         # UN, devlet uyarıları
            'market_signals': 0.20,          # VIX, petrol, altın
            'news_velocity': 0.15,           # Haber hızı artışı
            'social_media_surge': 0.10,      # Sosyal medya hacmi
            'satellite_anomaly': 0.10,       # Uydu anomalileri
        }
    
    def calculate_crisis_level(self, signals):
        """
        Her sinyal 0-100 arası normalize edilmiş skor.
        Toplam ağırlıklı skor → kriz seviyesi.
        """
        total = sum(
            signals[key] * self.weights[key] 
            for key in self.weights
        )
        
        if total >= 80: return 'CRITICAL'   # 🔴 Kırmızı alarm
        if total >= 60: return 'HIGH'       # 🟠 Yüksek risk
        if total >= 40: return 'ELEVATED'   # 🟡 Yükselmiş risk
        if total >= 20: return 'GUARDED'    # 🔵 Dikkat
        return 'LOW'                         # 🟢 Normal
```

### Kriz Doğrulama Kuralları
```
Bir olay CRISIS olarak etiketlenmeden önce:
1. En az 2 bağımsız kaynak doğrulamalı
2. En az 2 farklı katmandan sinyal gelmeli
3. Zaman penceresi: son 2 saat içinde sinyaller tutarlı olmalı
4. Coğrafi korelasyon: olaylar aynı bölgeden gelmeli
5. False positive filtresi: geçmiş yanlış alarmlarla karşılaştırma
```

---

## 📊 Kaynak Özet

| Katman | Kaynak Sayısı | Maliyet | Güncelleme |
|--------|--------------|---------|------------|
| OSINT Veritabanları | 6+ | Ücretsiz | 15dk - haftalık |
| Resmi Kurumlar | 15+ | Ücretsiz | Gerçek zamanlı |
| Piyasa Sinyalleri | 8+ | Ücretsiz | 1dk - 15dk |
| Sosyal Medya | 4+ platform | Ücretsiz/sınırlı | Gerçek zamanlı |
| Uydu/Sensör | 5+ | Ücretsiz | 15dk - günlük |
| **TOPLAM** | **38+ ana kaynak** | **$0 başlangıç** | **Karışık** |
