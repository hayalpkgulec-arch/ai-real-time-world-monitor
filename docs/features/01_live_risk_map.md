# 🗺️ Canlı Dünya Risk Haritası — Teknik Şartname

> 3D interaktif globe üzerinde gerçek zamanlı küresel risk görselleştirmesi.
> Ürünün **ana farklılaştırıcı özelliği** ve en yüksek ROI'li modülü.

---

## 🎯 Özellik Vizyonu

Kullanıcı uygulamayı açtığında karşısına dönen bir dünya küresi gelir.
Her ülke/bölge, **anlık risk seviyesine göre renklenir**. Kriz bölgeleri kırmızı yanar,
olay noktalarına tıklanınca AI analizi açılır.

**Hedef:** "Tek bakışta dünyanın durumunu anla."

---

## 🏗️ Teknik Mimari

```
┌────────────────────────────────────────────────────────┐
│                    FRONTEND KATMANI                     │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  3D Globe    │  │  2D Flat Map │  │  Region Zoom │ │
│  │  (globe.gl)  │  │  (mapbox/    │  │  (Detail     │ │
│  │              │  │   leaflet)   │  │   View)      │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
│         └─────────────┬───┘──────────────────┘         │
│                       │                                │
│            ┌──────────▼──────────┐                     │
│            │  Map State Manager  │                     │
│            │  (Zustand/Redux)    │                     │
│            └──────────┬──────────┘                     │
├───────────────────────┼────────────────────────────────┤
│                       │  WebSocket + REST API          │
├───────────────────────┼────────────────────────────────┤
│                 BACKEND KATMANI                        │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Risk Score  │  │  Event       │  │  GeoJSON     │ │
│  │  Calculator  │  │  Aggregator  │  │  Generator   │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
│         └─────────────┬───┘──────────────────┘         │
│                       │                                │
│            ┌──────────▼──────────┐                     │
│            │    Data Sources     │                     │
│            │  (ACLED, GDELT,     │                     │
│            │   RSS, Markets)     │                     │
│            └─────────────────────┘                     │
└────────────────────────────────────────────────────────┘
```

---

## 🌐 3D Globe Implementasyonu

### Teknoloji Seçimi

| Seçenek | Avantaj | Dezavantaj | Karar |
|---------|---------|------------|-------|
| **globe.gl** | Kolay, hızlı, Three.js tabanlı | Sınırlı özelleştirme | ✅ MVP için |
| **CesiumJS** | Profesyonel, uydu görüntüleri | Ağır, karmaşık | Faz 2 |
| **Three.js (custom)** | Full kontrol | Uzun geliştirme süresi | Faz 3 |
| **Mapbox GL** | 2D+2.5D, güçlü styling | Gerçek 3D globe yok | Yedek plan |

### Globe.gl Implementasyonu

```javascript
// === 3D GLOBE KONFIGÜRASYONU ===
import Globe from 'globe.gl';

const RISK_COLORS = {
  CRITICAL: '#FF1744',    // Kırmızı — savaş, büyük kriz
  HIGH:     '#FF6D00',    // Turuncu — yüksek risk
  ELEVATED: '#FFD600',    // Sarı — yükselen risk
  GUARDED:  '#2979FF',    // Mavi — dikkat
  LOW:      '#00E676',    // Yeşil — normal
};

const world = Globe()
  .globeImageUrl('//unpkg.com/three-globe/example/img/earth-dark.jpg')
  .bumpImageUrl('//unpkg.com/three-globe/example/img/earth-topology.png')
  .backgroundImageUrl('//unpkg.com/three-globe/example/img/night-sky.png')
  .showAtmosphere(true)
  .atmosphereColor('#3a228a')
  .atmosphereAltitude(0.25)
  // Ülke poligonları (risk renkleri)
  .polygonsData(countriesGeoJson.features)
  .polygonAltitude(d => d.properties.riskLevel === 'CRITICAL' ? 0.06 : 0.01)
  .polygonCapColor(d => RISK_COLORS[d.properties.riskLevel] + '90')
  .polygonSideColor(() => 'rgba(0, 100, 200, 0.15)')
  .polygonStrokeColor(() => '#111')
  .polygonLabel(d => `
    <div class="globe-tooltip">
      <h3>${d.properties.name}</h3>
      <span class="risk-badge ${d.properties.riskLevel}">
        ${d.properties.riskLevel}
      </span>
      <p>Risk Score: ${d.properties.riskScore}/100</p>
      <p>Active Events: ${d.properties.eventCount}</p>
    </div>
  `)
  // Olay noktaları (pulse efektli)
  .pointsData(activeEvents)
  .pointAltitude(0.07)
  .pointColor(d => RISK_COLORS[d.severity])
  .pointRadius(d => Math.sqrt(d.importance) * 0.05)
  .pointsMerge(false)
  // Olay bağlantı yayları (ilişkili olaylar arası)
  .arcsData(eventConnections)
  .arcColor(d => [RISK_COLORS[d.srcRisk], RISK_COLORS[d.dstRisk]])
  .arcAltitude(0.3)
  .arcStroke(0.5)
  .arcDashLength(0.4)
  .arcDashGap(0.2)
  .arcDashAnimateTime(1500)
  // Tıklama olayları
  .onPolygonClick(handleCountryClick)
  .onPointClick(handleEventClick)
  (document.getElementById('globe-container'));

// Otomatik döndürme
world.controls().autoRotate = true;
world.controls().autoRotateSpeed = 0.5;

// Kriz anında ilgili bölgeye zoom
function focusOnCrisis(lat, lng) {
  world.pointOfView({ lat, lng, altitude: 1.5 }, 1000);
  world.controls().autoRotate = false;
}
```

### Pulse Efektli Olay İşaretleyicileri

```javascript
// === CANLI OLAY PULSE ANİMASYONU ===
const createPulseRing = (event) => ({
  lat: event.latitude,
  lng: event.longitude,
  maxRadius: event.severity === 'CRITICAL' ? 8 : 4,
  propagationSpeed: event.severity === 'CRITICAL' ? 3 : 1.5,
  repeatPeriod: event.severity === 'CRITICAL' ? 800 : 1500,
  color: () => RISK_COLORS[event.severity],
  altitude: 0.005,
});

// Kritik olaylara nabız (pulse ring) ekle
world
  .ringsData(criticalEvents.map(createPulseRing))
  .ringColor('color')
  .ringMaxRadius('maxRadius')
  .ringPropagationSpeed('propagationSpeed')
  .ringRepeatPeriod('repeatPeriod');
```

---

## 🎨 Harita Görünüm Modları

### Mod 1: Global Risk Overview (Varsayılan)
```
- Tüm dünya görünür
- Ülkeler risk rengine göre boyalı
- Kritik olaylar pulse ile yanıp söner
- Yavaş otomatik döndürme
```

### Mod 2: Heat Map Overlay
```
- Risk yoğunluğu ısı haritası
- Olayların coğrafi yoğunlaşması
- Gradient: Yeşil → Sarı → Kırmızı
- Zaman dilimi filtresi: 1s / 24s / 7g / 30g
```

### Mod 3: Event Cluster View
```
- Benzer olaylar kümelere gruplandırılır
- Küme boyutu = olay sayısı
- Zoom'da kümeler parçalanır
- Her kümenin AI özet etiketi
```

### Mod 4: Market Impact View
```
- Harita renkleri piyasa etkisine göre
- Petrol üretici ülkeler: petrol fiyat etkisi
- Ticaret yolları: supply chain risk
- Finansal merkezler: borsa etkisi
```

### Mod 5: Timeline Replay
```
- Zaman çizelgesi slider'ı
- Olayların kronolojik oynatılması
- Hız kontrolü: 1x, 2x, 5x, 10x
- "Krizin gelişimi" görselleştirmesi
```

---

## 📊 Ülke Risk Skoru Hesaplama

```python
# === ÜLKE RİSK SKORU ALGORİTMASI ===

class CountryRiskCalculator:
    """Her ülke için 0-100 arası risk skoru hesaplar."""
    
    WEIGHTS = {
        'active_conflicts':      0.25,  # ACLED çatışma olayları
        'political_instability': 0.15,  # Siyasi istikrarsızlık
        'economic_stress':       0.15,  # Ekonomik kriz göstergeleri
        'natural_disaster_risk': 0.10,  # Doğal afet riski
        'social_unrest':         0.10,  # Protesto ve toplumsal huzursuzluk
        'news_sentiment':        0.10,  # Haber duygu analizi
        'market_volatility':     0.10,  # Piyasa oynaklığı
        'historical_trend':      0.05,  # Tarihsel trend
    }
    
    def calculate(self, country_code: str) -> dict:
        scores = {}
        
        # 1. Aktif çatışma skoru
        acled_events = self.get_acled_events(country_code, days=7)
        fatalities = sum(e['fatalities'] for e in acled_events)
        conflict_count = len([e for e in acled_events 
                             if e['event_type'] in ('Battles', 'Explosions')])
        scores['active_conflicts'] = min(100, conflict_count * 10 + fatalities * 2)
        
        # 2. Siyasi istikrarsızlık
        protests = len([e for e in acled_events if e['event_type'] == 'Protests'])
        gov_changes = self.get_government_changes(country_code, days=30)
        scores['political_instability'] = min(100, protests * 5 + gov_changes * 30)
        
        # 3. Ekonomik stres
        cds_spread = self.get_cds_spread(country_code)
        currency_change = self.get_currency_change(country_code, days=7)
        scores['economic_stress'] = min(100, 
            (cds_spread / 10) + (abs(currency_change) * 10))
        
        # 4. Doğal afet riski
        disasters = self.get_active_disasters(country_code)
        scores['natural_disaster_risk'] = min(100, len(disasters) * 25)
        
        # 5. Toplumsal huzursuzluk
        riot_events = len([e for e in acled_events if e['event_type'] == 'Riots'])
        scores['social_unrest'] = min(100, riot_events * 15)
        
        # 6. Haber duygu analizi
        sentiment = self.get_news_sentiment(country_code, hours=24)
        scores['news_sentiment'] = max(0, min(100, (1 - sentiment) * 50))
        
        # 7. Piyasa oynaklığı
        market_vol = self.get_market_volatility(country_code)
        scores['market_volatility'] = min(100, market_vol * 5)
        
        # 8. Tarihsel trend
        historical = self.get_historical_risk(country_code, days=90)
        scores['historical_trend'] = historical
        
        # Ağırlıklı toplam
        total = sum(
            scores[key] * self.WEIGHTS[key] for key in self.WEIGHTS
        )
        
        return {
            'country': country_code,
            'risk_score': round(total, 1),
            'risk_level': self._score_to_level(total),
            'breakdown': scores,
            'timestamp': datetime.utcnow().isoformat(),
        }
    
    def _score_to_level(self, score):
        if score >= 80: return 'CRITICAL'
        if score >= 60: return 'HIGH'
        if score >= 40: return 'ELEVATED'
        if score >= 20: return 'GUARDED'
        return 'LOW'
```

---

## 🔄 Gerçek Zamanlı Güncelleme Sistemi

```javascript
// === WEBSOCKET GERÇEK ZAMANLI GÜNCELLEME ===

class MapDataStream {
  constructor(globeInstance) {
    this.globe = globeInstance;
    this.ws = null;
    this.reconnectDelay = 1000;
  }

  connect() {
    this.ws = new WebSocket('wss://api.worldmonitor.app/ws/map');
    
    this.ws.onmessage = (message) => {
      const data = JSON.parse(message.data);
      
      switch (data.type) {
        case 'RISK_UPDATE':
          this.updateCountryRisk(data.payload);
          break;
        case 'NEW_EVENT':
          this.addEventPoint(data.payload);
          this.showEventNotification(data.payload);
          break;
        case 'EVENT_ESCALATION':
          this.escalateEvent(data.payload);
          break;
        case 'EVENT_RESOLVED':
          this.removeEventPoint(data.payload);
          break;
      }
    };

    this.ws.onclose = () => {
      setTimeout(() => this.connect(), this.reconnectDelay);
      this.reconnectDelay = Math.min(this.reconnectDelay * 2, 30000);
    };
  }

  updateCountryRisk(update) {
    // Ülke rengini smooth geçişle güncelle
    const features = this.globe.polygonsData();
    const country = features.find(f => 
      f.properties.iso3 === update.country_code
    );
    if (country) {
      country.properties.riskLevel = update.risk_level;
      country.properties.riskScore = update.risk_score;
      this.globe.polygonsData([...features]); // Trigger re-render
    }
  }

  addEventPoint(event) {
    const points = this.globe.pointsData();
    points.push({
      lat: event.latitude,
      lng: event.longitude,
      severity: event.severity,
      importance: event.importance,
      title: event.title,
      id: event.id,
    });
    this.globe.pointsData([...points]);
    
    // Kritik olaylarda otomatik zoom
    if (event.severity === 'CRITICAL') {
      this.globe.pointOfView(
        { lat: event.latitude, lng: event.longitude, altitude: 1.5 },
        1500
      );
    }
  }
}
```

---

## 📱 React Native Mobile Entegrasyonu

```javascript
// === REACT NATIVE MAP COMPONENT ===
import React, { useRef, useEffect, useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Text } from 'react-native';
import { WebView } from 'react-native-webview';

const RiskGlobe = ({ onEventSelect, onCountrySelect }) => {
  const webViewRef = useRef(null);
  const [viewMode, setViewMode] = useState('globe'); // globe | flat | heatmap

  const injectGlobeHTML = `
    <!DOCTYPE html>
    <html>
    <head>
      <script src="//unpkg.com/globe.gl"></script>
      <style>
        body { margin: 0; background: #0a0a1a; overflow: hidden; }
        #globe { width: 100vw; height: 100vh; }
      </style>
    </head>
    <body>
      <div id="globe"></div>
      <script>
        // Globe initialization code here
        // Posts messages to React Native via window.ReactNativeWebView
      </script>
    </body>
    </html>
  `;

  return (
    <View style={styles.container}>
      <WebView
        ref={webViewRef}
        source={{ html: injectGlobeHTML }}
        style={styles.webview}
        onMessage={(event) => {
          const data = JSON.parse(event.nativeEvent.data);
          if (data.type === 'eventClick') onEventSelect(data.event);
          if (data.type === 'countryClick') onCountrySelect(data.country);
        }}
      />
      
      {/* Görünüm modu değiştirme butonları */}
      <View style={styles.modeSelector}>
        <TouchableOpacity 
          style={[styles.modeBtn, viewMode === 'globe' && styles.active]}
          onPress={() => setViewMode('globe')}>
          <Text style={styles.modeTxt}>🌍 Globe</Text>
        </TouchableOpacity>
        <TouchableOpacity 
          style={[styles.modeBtn, viewMode === 'flat' && styles.active]}
          onPress={() => setViewMode('flat')}>
          <Text style={styles.modeTxt}>🗺️ Flat</Text>
        </TouchableOpacity>
        <TouchableOpacity 
          style={[styles.modeBtn, viewMode === 'heatmap' && styles.active]}
          onPress={() => setViewMode('heatmap')}>
          <Text style={styles.modeTxt}>🔥 Heat</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0a0a1a' },
  webview: { flex: 1 },
  modeSelector: {
    position: 'absolute', bottom: 20, alignSelf: 'center',
    flexDirection: 'row', backgroundColor: 'rgba(10,10,26,0.9)',
    borderRadius: 25, padding: 4, borderWidth: 1, borderColor: '#2a2a4a',
  },
  modeBtn: { paddingHorizontal: 16, paddingVertical: 8, borderRadius: 20 },
  active: { backgroundColor: '#3a228a' },
  modeTxt: { color: '#fff', fontSize: 13 },
});
```

---

## 🌊 Deneyim Akışı (User Flow)

```
1. Uygulama açılır → Dönen dünya küresi
2. Kullanıcı kırmızı bir bölge görür → Meraklanır
3. Bölgeye dokunur → Zoom + olay listesi açılır
4. Olaya dokunur → AI analiz kartı:
   ┌──────────────────────────────┐
   │ 🔴 Orta Doğu Askeri Gerilim │
   │                              │
   │ 📈 Piyasa Etkisi:           │
   │    Petrol: ↑ +4.2%          │
   │    Altın:  ↑ +1.8%          │
   │                              │
   │ 🧠 AI Özet:                 │
   │ "Bölgedeki askeri harekat    │
   │  petrol arz riskini artırdı" │
   │                              │
   │ 📊 Güven: 78% | Risk: HIGH  │
   │                              │
   │ [Detaylar] [Paylaş] [Uyarı] │
   └──────────────────────────────┘
5. "Paylaş" → Sosyal medya kartı oluşturulur → Viral
```

---

## 📐 Backend API Endpoints

```
GET  /api/v1/map/countries
     → Tüm ülkelerin risk skorları + GeoJSON

GET  /api/v1/map/events?lat={lat}&lng={lng}&radius={km}
     → Belirli bölgedeki aktif olaylar

GET  /api/v1/map/events/active
     → Tüm aktif olaylar (harita noktaları)

GET  /api/v1/map/heatmap?timeframe=24h
     → Isı haritası grid verileri

WS   /ws/map
     → Gerçek zamanlı risk güncellemeleri

GET  /api/v1/map/country/{iso3}
     → Tek ülke detay (risk breakdown, olaylar, tarihçe)

GET  /api/v1/map/connections
     → Olaylar arası bağlantı yayları
```

---

## 📋 Geliştirme Fazları

| Faz | Süre | Çıktı |
|-----|------|-------|
| **Faz 1** | 2 hafta | Statik GeoJSON + risk renkleri ile globe.gl MVP |
| **Faz 2** | 2 hafta | Gerçek zamanlı olay noktaları + pulse animasyonları |
| **Faz 3** | 2 hafta | WebSocket canlı güncelleme + tıklama detayları |
| **Faz 4** | 1 hafta | Heat map overlay + zaman slider |
| **Faz 5** | 1 hafta | React Native entegrasyonu |
| **Faz 6** | 2 hafta | Performance optimizasyonu + offline cache |
