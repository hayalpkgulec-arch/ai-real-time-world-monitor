const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(cors());
app.use(express.json());

// === ÜLKE RİSK SKORU HESAPLAMA SİSTEMİ ===

class CountryRiskCalculator {
    constructor() {
        this.WEIGHTS = {
            'active_conflicts': 0.25,      // ACLED çatışma olayları
            'political_instability': 0.15,  // Siyasi istikrarsızlık
            'economic_stress': 0.15,       // Ekonomik kriz göstergeleri
            'natural_disaster_risk': 0.10,  // Doğal afet riski
            'social_unrest': 0.10,         // Protesto ve toplumsal huzursuzluk
            'news_sentiment': 0.10,          // Haber duygu analizi
            'market_volatility': 0.10,       // Piyasa oynaklığı
            'historical_trend': 0.05,          // Tarihsel trend
        };
        
        this.cache = new Map();
        this.cacheTimeout = 5 * 60 * 1000; // 5 dakika
    }

    async calculate(country_code) {
        // Cache kontrolü
        const cached = this.cache.get(country_code);
        if (cached && Date.now() - cached.timestamp < this.cacheTimeout) {
            return cached.data;
        }

        const scores = {};
        
        try {
            // 1. Aktif çatışma skoru
            const acled_events = await this.getACLEDEvents(country_code);
            const fatalities = acled_events.reduce((sum, e) => sum + (e.fatalities || 0), 0);
            const conflict_count = acled_events.filter(e => 
                ['Battles', 'Explosions', 'Violence against civilians'].includes(e.event_type)
            ).length;
            scores.active_conflicts = Math.min(100, conflict_count * 10 + fatalities * 2);
            
            // 2. Siyasi istikrarsızlık
            const protests = acled_events.filter(e => e.event_type === 'Protests').length;
            const gov_changes = await this.getGovernmentChanges(country_code);
            scores.political_instability = Math.min(100, protests * 5 + gov_changes * 30);
            
            // 3. Ekonomik stres
            const cds_spread = await this.getCDSSpread(country_code);
            const currency_change = await this.getCurrencyChange(country_code);
            scores.economic_stress = Math.min(100, 
                (cds_spread / 10) + (Math.abs(currency_change) * 10));
            
            // 4. Doğal afet riski
            const disasters = await this.getActiveDisasters(country_code);
            scores.natural_disaster_risk = Math.min(100, disasters.length * 25);
            
            // 5. Toplumsal huzursuzluk
            const riot_events = acled_events.filter(e => e.event_type === 'Riots').length;
            scores.social_unrest = Math.min(100, riot_events * 15);
            
            // 6. Haber duygu analizi
            const sentiment = await this.getNewsSentiment(country_code);
            scores.news_sentiment = Math.max(0, Math.min(100, (1 - sentiment) * 50));
            
            // 7. Piyasa oynaklığı
            const market_vol = await this.getMarketVolatility(country_code);
            scores.market_volatility = Math.min(100, market_vol * 5);
            
            // 8. Tarihsel trend
            const historical = await this.getHistoricalRisk(country_code);
            scores.historical_trend = historical;
            
            // Ağırlıklı toplam
            const total = Object.keys(this.WEIGHTS).reduce((sum, key) => {
                return sum + (scores[key] || 0) * this.WEIGHTS[key];
            }, 0);
            
            const result = {
                country: country_code,
                risk_score: Math.round(total * 10) / 10,
                risk_level: this.scoreToLevel(total),
                breakdown: scores,
                timestamp: new Date().toISOString(),
            };

            // Cache'e kaydet
            this.cache.set(country_code, {
                data: result,
                timestamp: Date.now()
            });

            return result;
            
        } catch (error) {
            console.error(`Risk calculation failed for ${country_code}:`, error);
            return this.getDefaultRisk(country_code);
        }
    }

    scoreToLevel(score) {
        if (score >= 80) return 'CRITICAL';
        if (score >= 60) return 'HIGH';
        if (score >= 40) return 'ELEVATED';
        if (score >= 20) return 'GUARDED';
        return 'LOW';
    }

    getDefaultRisk(country_code) {
        return {
            country: country_code,
            risk_score: 25.0,
            risk_level: 'GUARDED',
            breakdown: {},
            timestamp: new Date().toISOString(),
        };
    }

    // Mock metodlar (gerçek implementasyonlar)
    async getACLEDEvents(country_code) {
        // ACLED API entegrasyonu buraya gelecek
        return [
            { event_type: 'Battles', fatalities: 5 },
            { event_type: 'Protests', fatalities: 0 }
        ];
    }

    async getGovernmentChanges(country_code) {
        return 0;
    }

    async getCDSSpread(country_code) {
        return 15.5;
    }

    async getCurrencyChange(country_code) {
        return 0.02;
    }

    async getActiveDisasters(country_code) {
        return [];
    }

    async getNewsSentiment(country_code) {
        return 0.7; // %70 negatif duygu
    }

    async getMarketVolatility(country_code) {
        return 3.2;
    }

    async getHistoricalRisk(country_code) {
        return 30;
    }
}

const riskCalculator = new CountryRiskCalculator();

// === API ENDPOINTS ===

// Tüm ülkelerin risk skorları
app.get('/api/v1/map/countries', async (req, res) => {
    try {
        const countries = ['USA', 'CHN', 'RUS', 'IRN', 'ISR', 'UKR', 'TWN'];
        const results = await Promise.all(
            countries.map(country => riskCalculator.calculate(country))
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

// Belirli bir ülkenin detaylı risk bilgisi
app.get('/api/v1/map/country/:iso3', async (req, res) => {
    try {
        const { iso3 } = req.params;
        const result = await riskCalculator.calculate(iso3.toUpperCase());
        
        res.json({
            success: true,
            data: result
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Aktif olaylar (mock)
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

// Belirli bölgedeki olaylar
app.get('/api/v1/map/events', async (req, res) => {
    try {
        const { lat, lng, radius = 50 } = req.query;
        
        // Bölgedeki olayları bul (mock)
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
            // Basit mesafe hesabı
            const eventLat = event.latitude;
            const eventLng = event.longitude;
            const distance = Math.sqrt(
                Math.pow(parseFloat(lat) - eventLat, 2) + 
                Math.pow(parseFloat(lng) - eventLng, 2)
            ) * 111; // Yaklaşım km
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

// Heat map verileri
app.get('/api/v1/map/heatmap', async (req, res) => {
    try {
        const { timeframe = '24h' } = req.query;
        
        // Mock heat map grid verisi
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

// Olay bağlantıları
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
        res.status(500).json.status(500).json({ success: false, error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🗺️ Risk Map API server running on port ${PORT}`);
    console.log('📊 Available endpoints:');
    console.log('  GET /api/v1/map/countries');
    console.log('  GET /api/v1/map/country/:iso3');
    console.log('  GET /api/v1/map/events/active');
    console.log('  GET /api/v1/map/events');
    console.log('  GET /api/v1/map/heatmap');
    console.log('  GET /api/v1/map/connections');
});
