# 🔔 Smart Alert System — Teknik Şartname

> Bağlamsal, portföy bazlı ve akıllı bildirim sistemi.
> Doğru zamanda, doğru bilgiyi, doğru kullanıcıya ulaştırır.

---

## 🎯 Vizyon

Geleneksel push notification'lardan farklı olarak, bu sistem **kullanıcının bağlamını anlar**:
- Hangi varlıklara sahip?
- Hangi bölgeleri izliyor?
- Ne zaman müsait?
- Hangi tür olayları önemsiyor?

---

## 🏗️ Sistem Mimarisi

```
┌─────────────────────────────────────────────┐
│              EVENT DETECTION                │
│         (Kriz Tespit Motoru)                │
└──────────────────┬──────────────────────────┘
                   │ raw events
                   ▼
┌─────────────────────────────────────────────┐
│           ALERT ENGINE (Core)               │
│                                             │
│  ┌────────────┐ ┌────────────┐ ┌─────────┐ │
│  │ Relevance  │ │ Priority   │ │ Fatigue │ │
│  │ Matcher    │ │ Calculator │ │ Guard   │ │
│  └─────┬──────┘ └─────┬──────┘ └────┬────┘ │
│        └──────────┬───┘─────────────┘      │
│                   ▼                         │
│        ┌──────────────────┐                 │
│        │ Alert Dispatcher │                 │
│        └────────┬─────────┘                 │
└─────────────────┼───────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    ▼             ▼             ▼
┌────────┐  ┌─────────┐  ┌──────────┐
│  Push  │  │  Email  │  │ In-App   │
│ Notif  │  │ Digest  │  │ Banner   │
└────────┘  └─────────┘  └──────────┘
```

---

## 📋 Alert Tipleri

### Tip 1: 🔴 Breaking Crisis Alert
```json
{
  "type": "BREAKING_CRISIS",
  "priority": "CRITICAL",
  "bypass_quiet_hours": true,
  "bypass_daily_limit": true,
  "title": "🔴 MAJOR: Orta Doğu'da askeri çatışma tırmanıyor",
  "body": "3 ülke havadan operasyon başlattı. Petrol +6.2% yükseldi.",
  "action": { "type": "open_event", "event_id": "evt_12345" },
  "channels": ["push", "in_app", "email"],
  "sound": "critical_alert",
  "conditions": {
    "risk_level": "CRITICAL",
    "min_sources": 3,
    "min_confidence": 0.8
  }
}
```

### Tip 2: 💼 Portfolio Impact Alert
```json
{
  "type": "PORTFOLIO_IMPACT",
  "priority": "HIGH",
  "title": "💼 Portföyünüz etkilenebilir",
  "body": "İzlediğiniz enerji hisseleri Orta Doğu geriliminden etkilendi. XLE -3.2%",
  "action": { "type": "open_portfolio_impact", "event_id": "evt_12345" },
  "conditions": {
    "user_has_affected_assets": true,
    "impact_threshold_pct": 2.0
  },
  "personalization": {
    "affected_assets": ["XLE", "USO", "BP"],
    "estimated_portfolio_impact": "-2.1%"
  }
}
```

### Tip 3: 📍 Watchlist Region Alert
```json
{
  "type": "WATCHLIST_ALERT",
  "priority": "MEDIUM",
  "title": "📍 İzlediğiniz bölgede yeni olay",
  "body": "Tayvan Boğazı'nda artan askeri tatbikat tespit edildi",
  "conditions": {
    "region_in_watchlist": true,
    "event_importance": ">= 60"
  }
}
```

### Tip 4: 📈 Escalation Alert
```json
{
  "type": "ESCALATION",
  "priority": "HIGH",
  "title": "⬆️ Takip ettiğiniz olay tırmanıyor",
  "body": "Rusya-Ukrayna: Risk seviyesi HIGH → CRITICAL'e yükseldi",
  "conditions": {
    "user_viewed_event": true,
    "risk_level_increased": true
  }
}
```

### Tip 5: 💡 Opportunity Alert
```json
{
  "type": "OPPORTUNITY",
  "priority": "LOW",
  "title": "💡 Kriz sonrası fırsat sinyali",
  "body": "Altın son 3 günde %8 düştü. Tarihsel olarak benzer düşüşlerin %72'si toparlanma ile sonuçlandı.",
  "conditions": {
    "post_crisis_recovery_signal": true,
    "historical_pattern_match": "> 0.7"
  }
}
```

### Tip 6: 🌍 Trend Alert
```json
{
  "type": "TREND_ALERT",
  "priority": "LOW",
  "title": "🌍 Yeni küresel trend tespit edildi",
  "body": "AI düzenlemesi tartışmaları 15 ülkede eş zamanlı hız kazandı. Trend Skoru: 87",
  "conditions": {
    "trend_score": ">= 80",
    "multi_region": true
  }
}
```

---

## 🧠 Relevance Matching Engine

```python
class RelevanceMatcher:
    """Bir olayın belirli bir kullanıcı için ne kadar relevant olduğunu hesaplar."""
    
    def calculate_relevance(self, event, user_profile) -> float:
        score = 0.0
        weights = []
        
        # 1. Portföy etkisi (en yüksek ağırlık)
        portfolio_impact = self._check_portfolio_impact(event, user_profile)
        if portfolio_impact > 0:
            score += portfolio_impact * 0.35
            weights.append(0.35)
        
        # 2. Watchlist bölge eşleşmesi
        region_match = self._check_watchlist_region(event, user_profile)
        if region_match:
            score += 0.25
            weights.append(0.25)
        
        # 3. İlgi alanı eşleşmesi
        topic_match = self._check_topic_interest(event, user_profile)
        score += topic_match * 0.20
        weights.append(0.20)
        
        # 4. Tarihsel etkileşim
        engagement = self._check_engagement_history(event, user_profile)
        score += engagement * 0.10
        weights.append(0.10)
        
        # 5. Olayın global önemi (herkesi ilgilendirir)
        global_importance = event.importance / 100
        score += global_importance * 0.10
        weights.append(0.10)
        
        return min(1.0, score)
    
    def _check_portfolio_impact(self, event, user):
        """Kullanıcının portföyündeki varlıkların etkilenme oranı."""
        affected = []
        for asset in user.portfolio:
            for impact in event.market_impacts:
                if asset.sector == impact.sector or asset.symbol in impact.symbols:
                    affected.append({
                        'asset': asset,
                        'impact_pct': impact.predicted_change,
                    })
        
        if not affected:
            return 0.0
        
        total_exposure = sum(a['asset'].weight * abs(a['impact_pct']) for a in affected)
        return min(1.0, total_exposure / 5)  # %5 ve üzeri = max skor
```

---

## 🛡️ Notification Fatigue Guard

```python
class FatigueGuard:
    """Kullanıcıyı bildirim yorgunluğundan korur."""
    
    LIMITS = {
        'CRITICAL': {'daily': 5,   'hourly': 3,  'min_interval_minutes': 5},
        'HIGH':     {'daily': 8,   'hourly': 3,  'min_interval_minutes': 15},
        'MEDIUM':   {'daily': 5,   'hourly': 2,  'min_interval_minutes': 30},
        'LOW':      {'daily': 3,   'hourly': 1,  'min_interval_minutes': 60},
    }
    
    QUIET_HOURS_DEFAULT = {
        'start': '23:00',
        'end': '07:00',
        'timezone': 'user_local',
        'bypass_for': ['CRITICAL'],  # Kritik uyarılar sessiz saatlerden muaf
    }
    
    def should_send(self, alert, user) -> tuple[bool, str]:
        priority = alert.priority
        limits = self.LIMITS[priority]
        
        # 1. Sessiz saat kontrolü
        if self._is_quiet_hours(user) and priority not in self.QUIET_HOURS_DEFAULT['bypass_for']:
            return False, "quiet_hours"
        
        # 2. Günlük limit kontrolü
        today_count = self._get_sent_count(user, priority, hours=24)
        if today_count >= limits['daily']:
            return False, "daily_limit_reached"
        
        # 3. Saatlik limit kontrolü
        hour_count = self._get_sent_count(user, priority, hours=1)
        if hour_count >= limits['hourly']:
            return False, "hourly_limit_reached"
        
        # 4. Minimum aralık kontrolü
        last_sent = self._get_last_sent_time(user, priority)
        if last_sent and (now() - last_sent).minutes < limits['min_interval_minutes']:
            return False, "too_soon"
        
        # 5. Benzer bildirim kontrolü (dedup)
        if self._is_similar_to_recent(alert, user, hours=4):
            return False, "similar_alert_sent"
        
        return True, "approved"
    
    def _smart_batch(self, pending_alerts, user):
        """Düşük öncelikli uyarıları grupla ve digest olarak gönder."""
        low_priority = [a for a in pending_alerts if a.priority in ('LOW', 'MEDIUM')]
        
        if len(low_priority) >= 3:
            return self._create_digest(low_priority, user)
        return pending_alerts
```

---

## ⚙️ Kullanıcı Alert Tercihleri

```javascript
// === ALERT PREFERENCES UI ===
const defaultPreferences = {
  // Genel ayarlar
  pushEnabled: true,
  emailDigest: 'daily',           // 'realtime' | 'daily' | 'weekly' | 'off'
  inAppBanner: true,
  sound: true,
  vibration: true,
  
  // Sessiz saatler
  quietHours: {
    enabled: true,
    start: '23:00',
    end: '07:00',
    timezone: 'auto',             // Cihaz timezone'u
  },
  
  // Öncelik filtreleri
  minimumPriority: 'MEDIUM',      // CRITICAL | HIGH | MEDIUM | LOW
  breakingAlertsBypass: true,      // Kritik olaylar tüm filtreleri bypass eder
  
  // Portföy
  portfolioAlerts: true,
  portfolioImpactThreshold: 2.0,  // %2 ve üzeri değişimde uyarı
  
  // Watchlist
  watchlistRegions: ['middle_east', 'east_asia', 'europe'],
  watchlistTopics: ['oil', 'gold', 'tech_regulation', 'military'],
  watchlistCountries: ['US', 'CN', 'RU', 'IR', 'TW'],
  
  // İleri seviye
  trendAlerts: true,
  opportunityAlerts: false,
  escalationAlerts: true,
  weeklyReport: true,
};
```

---

## 📐 Backend API

```
POST /api/v1/alerts/preferences
     → Kullanıcı alert tercihlerini kaydet

GET  /api/v1/alerts/preferences
     → Mevcut tercihleri getir

GET  /api/v1/alerts/history?page=1&limit=20
     → Geçmiş alert'ler

POST /api/v1/alerts/test
     → Test alert gönder

PUT  /api/v1/alerts/{id}/read
     → Alert'i okundu olarak işaretle

POST /api/v1/alerts/portfolio
     → Portföy varlıklarını güncelle

POST /api/v1/alerts/watchlist
     → Watchlist'i güncelle
```

---

## 📋 Geliştirme Fazları

| Faz | Süre | Çıktı |
|-----|------|-------|
| **Faz 1** | 1 hafta | Temel push notification altyapısı (FCM/APNs) |
| **Faz 2** | 1 hafta | Alert tipleri + öncelik sistemi |
| **Faz 3** | 2 hafta | Relevance matcher + portföy entegrasyonu |
| **Faz 4** | 1 hafta | Fatigue guard + sessiz saatler |
| **Faz 5** | 1 hafta | Kullanıcı tercihleri UI |
| **Faz 6** | 1 hafta | Email digest sistemi |
