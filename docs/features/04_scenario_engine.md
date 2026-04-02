# 📊 Senaryo Motoru — Teknik Şartname

> "Eğer X olursa piyasalar ne yapar?" simülasyonu.
> Tarihsel korelasyonlar + AI tahminleri ile gelecek senaryoları üretir.

---

## 🎯 Vizyon

Kullanıcı bir **"what-if" senaryosu** seçer veya tanımlar.
Sistem, tarihsel veriler ve AI analizi kullanarak **olası sonuçları simüle eder**.
Yatırımcılar, analistler ve risk yöneticileri için **karar destek aracı**.

---

## 🏗️ Sistem Mimarisi

```
┌─────────────────────────────────────────────────────┐
│              SENARYO GİRDİSİ                        │
│  "İran-İsrail çatışması tırmanırsa"                 │
└──────────────────────┬──────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│           SCENARIO PARSER                            │
│  → Olayı kategorize et                               │
│  → İlgili varlıkları belirle                         │
│  → Zaman ufkunu belirle                              │
└──────────────────────┬──────────────────────────────┘
                       ▼
         ┌─────────────┴─────────────┐
         ▼                           ▼
┌─────────────────┐        ┌─────────────────┐
│  TARIHSEL       │        │  AI TAHMİN      │
│  ANALİZ         │        │  MOTORU          │
│                 │        │                 │
│  Benzer geçmiş  │        │  LLM tabanlı    │
│  olayları bul   │        │  neden-sonuç    │
│  ve sonuçlarını │        │  analizi        │
│  analiz et      │        │                 │
└────────┬────────┘        └────────┬────────┘
         └─────────────┬────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│           MONTE CARLO SİMÜLASYONU                    │
│  → 10,000 senaryo simülasyonu                        │
│  → Olasılık dağılımı                                 │
│  → Güven aralıkları                                  │
└──────────────────────┬──────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────┐
│           SONUÇ GÖRSELLEŞTİRME                      │
│  → Fan chart (olasılık yelpazesi)                    │
│  → Senaryo karşılaştırma tablosu                     │
│  → Risk/fırsat haritası                              │
└─────────────────────────────────────────────────────┘
```

---

## 💡 Hazır Senaryo Şablonları

### Kategori: Askeri Çatışma
```
┌─────────────────────────────────────────┐
│ ⚔️ ASKERI ÇATIŞMA SENARYOLARI           │
│                                          │
│ 🔴 İran-İsrail doğrudan çatışması       │
│ 🔴 Tayvan Boğazı krizi tırmanması       │
│ 🟠 Kuzey Kore provokasyonu              │
│ 🟠 NATO-Rusya gerilimi artışı           │
│ 🟡 Hint-Pakistan sınır gerilimi         │
│ 🟡 Güney Çin Denizi çatışması           │
└─────────────────────────────────────────┘
```

### Kategori: Ekonomik Kriz
```
┌─────────────────────────────────────────┐
│ 💰 EKONOMİK KRİZ SENARYOLARI           │
│                                          │
│ 🔴 ABD resesyona girerse                │
│ 🔴 Çin emlak krizi derinleşirse         │
│ 🟠 Fed acil faiz artırımı yaparsa       │
│ 🟠 Avrupa enerji krizi yeniden başlarsa │
│ 🟡 Gelişen ülke borç krizi              │
│ 🟡 Küresel ticaret savaşı genişlerse    │
└─────────────────────────────────────────┘
```

### Kategori: Doğal Afet & İklim
```
┌─────────────────────────────────────────┐
│ 🌊 DOĞAL AFET SENARYOLARI              │
│                                          │
│ 🔴 Mega deprem (Tokyo / İstanbul)       │
│ 🟠 Büyük volkanik patlama               │
│ 🟡 Kategori 5 kasırga (ABD)             │
│ 🟡 Küresel kuraklık krizi               │
└─────────────────────────────────────────┘
```

---

## 📊 Örnek Senaryo Çıktısı

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SENARYO: İran-İsrail Doğrudan Çatışması
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏱️ Zaman Ufku: 30 gün
🎯 Gerçekleşme Olasılığı: %22 (mevcut verilere göre)

┌──────────────────────────────────────────┐
│ VARLIK          │ SENARYO    │ OLASILIK  │
│─────────────────┼────────────┼───────────│
│ Brent Petrol    │ +15-30%    │ %78       │
│ Altın           │ +8-15%     │ %82       │
│ S&P 500         │ -5-12%     │ %70       │
│ VIX             │ +50-120%   │ %85       │
│ USD/TRY         │ +3-8%      │ %65       │
│ Bitcoin         │ ±15-25%    │ %60       │
│ Doğalgaz (EU)   │ +20-40%    │ %55       │
│ Savunma hisse.  │ +5-15%     │ %72       │
│ Havayolu his.   │ -8-20%     │ %68       │
└──────────────────────────────────────────┘

📈 Tarihsel Referanslar:
• 1990 Körfez Savaşı → Petrol %130↑, S&P -%20
• 2003 Irak İşgali → Petrol %40↑, Altın +15%
• 2020 Süleymani → Petrol +4%, kısa vadeli etki
• 2023 Gaza Krizi → Petrol +7%, VIX +25%

💡 AI Değerlendirme:
"Doğrudan bir İran-İsrail çatışması, Hürmüz 
Boğazı'nın kapatılma riski nedeniyle küresel petrol
arzını tehdit eder. Günde ~21M varil petrol bu 
boğazdan geçer. Askeri operasyonun boyutuna bağlı 
olarak etki 2 hafta - 6 ay sürebilir."

⚠️ Portföy Etkisi (sizin portföyünüz):
  Tahmini etki: -%4.3 ile -%8.7 arası
  En çok etkilenen: XLE (-12%), AAPL (-6%)
  Hedge önerisi: GLD long, VIX call
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🧠 Tarihsel Korelasyon Motoru

```python
class HistoricalCorrelationEngine:
    """Tarihsel olayları analiz ederek piyasa etkisi tahmin eder."""
    
    # Tarihsel olay veritabanı
    HISTORICAL_EVENTS = {
        'military_conflict_middle_east': [
            {
                'event': '1990 Gulf War',
                'oil_change': +130, 'gold_change': +10,
                'sp500_change': -20, 'duration_days': 210,
            },
            {
                'event': '2003 Iraq Invasion',
                'oil_change': +40, 'gold_change': +15,
                'sp500_change': -15, 'duration_days': 45,
            },
            # ... 20+ tarihsel olay
        ],
        'economic_crisis': [...],
        'pandemic': [...],
        'trade_war': [...],
        'natural_disaster': [...],
    }
    
    def find_analogues(self, scenario_type: str, severity: str) -> list:
        """Benzer tarihsel olayları bul ve sırala."""
        events = self.HISTORICAL_EVENTS.get(scenario_type, [])
        
        # Severity'e göre filtrele ve benzerliklere göre sırala
        scored = []
        for event in events:
            similarity = self._calculate_similarity(
                event, severity, current_conditions=self._get_current_state()
            )
            scored.append({**event, 'similarity_score': similarity})
        
        return sorted(scored, key=lambda x: x['similarity_score'], reverse=True)[:5]
    
    def predict_impact(self, scenario_type: str, asset: str) -> dict:
        """Tarihsel verilere dayanarak varlık etkisi tahmin et."""
        analogues = self.find_analogues(scenario_type, severity='high')
        
        changes = [a[f'{asset}_change'] for a in analogues if f'{asset}_change' in a]
        
        return {
            'asset': asset,
            'predicted_range': {
                'min': np.percentile(changes, 10),
                'max': np.percentile(changes, 90),
                'median': np.median(changes),
            },
            'confidence': len(changes) / 10,  # Daha fazla veri = daha yüksek güven
            'historical_count': len(changes),
        }
```

---

## 🎲 Monte Carlo Simülasyonu

```python
class MonteCarloSimulator:
    """10K senaryo simülasyonu ile olasılık dağılımı üretir."""
    
    def simulate(self, scenario, assets, num_simulations=10000) -> dict:
        results = {asset: [] for asset in assets}
        
        for _ in range(num_simulations):
            for asset in assets:
                # Tarihsel dağılımdan örnekle
                historical = self.correlation_engine.predict_impact(
                    scenario.type, asset
                )
                base = historical['predicted_range']['median']
                std = (historical['predicted_range']['max'] - 
                       historical['predicted_range']['min']) / 4
                
                # Normal dağılımdan rastgele çek
                simulated = np.random.normal(base, std)
                
                # Mevcut koşulları faktöre et
                adjustment = self._current_condition_adjustment(asset, scenario)
                simulated *= adjustment
                
                results[asset].append(simulated)
        
        # İstatistiksel özet
        summary = {}
        for asset in assets:
            data = results[asset]
            summary[asset] = {
                'mean': np.mean(data),
                'median': np.median(data),
                'std': np.std(data),
                'p10': np.percentile(data, 10),  # En kötü %10
                'p25': np.percentile(data, 25),
                'p75': np.percentile(data, 75),
                'p90': np.percentile(data, 90),  # En iyi %10
                'probability_negative': np.mean([1 for d in data if d < 0]),
                'probability_positive': np.mean([1 for d in data if d > 0]),
            }
        
        return summary
```

---

## 📱 UI Tasarımı

### Senaryo Seçim Ekranı
```
┌─────────────────────────────────────────┐
│  📊 Senaryo Simülatörü                 │
│                                          │
│  🔥 Popüler Senaryolar                  │
│  ┌───────────────────────────────────┐  │
│  │ ⚔️ İran-İsrail Çatışması        │  │
│  │    Olasılık: %22 | Etki: Yüksek  │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ 📉 ABD Resesyonu                 │  │
│  │    Olasılık: %35 | Etki: Çok Y.  │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ 🇨🇳 Çin Emlak Krizi              │  │
│  │    Olasılık: %45 | Etki: Yüksek  │  │
│  └───────────────────────────────────┘  │
│                                          │
│  ✏️ Kendi senaryonu oluştur             │
│  ┌───────────────────────────────────┐  │
│  │ "Eğer ______ olursa..."          │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Sonuç Görselleştirme — Fan Chart
```
    Olasılık yelpazesi (30 günlük Petrol tahmini)
    
    $120 ┤                              ╱ p90
    $110 ┤                          ╱╱╱╱
    $100 ┤                      ╱╱╱╱╱╱╱╱  p75
     $95 ┤                  ▓▓▓▓▓▓▓▓▓▓▓▓  median
     $90 ┤              ▓▓▓▓▓▓▓▓▓▓▓▓▓▓
     $87 ┤─────● bugün ╲╲╲╲╲╲╲╲╲╲        p25
     $80 ┤              ╲╲╲╲╲╲╲╲
     $75 ┤                  ╲╲╲╲          p10
         └────┬────┬────┬────┬────┬────┬──
             0d   5d  10d  15d  20d  25d 30d

    ▓▓▓ = %50 olasılık bandı
    ╱╱╱ = %80 olasılık bandı
    ─── = Mevcut fiyat
```

---

## 📐 Backend API

```
GET  /api/v1/scenarios/templates
     → Hazır senaryo şablonları

POST /api/v1/scenarios/simulate
     Body: { scenario_type, severity, assets, time_horizon_days }
     → Simülasyon sonuçları

GET  /api/v1/scenarios/{id}/results
     → Kaydedilmiş simülasyon sonuçları

POST /api/v1/scenarios/custom
     Body: { description, affected_regions, severity }
     → AI ile custom senaryo analizi

GET  /api/v1/scenarios/trending
     → Güncel popüler senaryolar (gerçek risk verilerine göre)

POST /api/v1/scenarios/{id}/portfolio-impact
     Body: { portfolio }
     → Senaryonun portföye etkisi
```

---

## 📋 Geliştirme Fazları

| Faz | Süre | Çıktı |
|-----|------|-------|
| **Faz 1** | 2 hafta | Tarihsel olay veritabanı + korelasyon motoru |
| **Faz 2** | 2 hafta | Monte Carlo simülasyonu + basit sonuç gösterimi |
| **Faz 3** | 2 hafta | AI tabanlı custom senaryo analizi (LLM) |
| **Faz 4** | 1 hafta | Fan chart + görselleştirme |
| **Faz 5** | 1 hafta | Portföy etki analizi entegrasyonu |
| **Faz 6** | 1 hafta | Trending senaryolar + topluluk tahminleri |

---

## 🛡️ Yasal Uyarı Notu

```
Her senaryo sonucu ekranında gösterilecek:

⚠️ YASAL UYARI: Bu simülasyon, tarihsel verilere ve yapay zeka 
tahminlerine dayanmaktadır. Yatırım tavsiyesi niteliği taşımaz. 
Geçmiş performans gelecek sonuçların garantisi değildir.
Yatırım kararlarınızda profesyonel danışmanlık almanız önerilir.
```
