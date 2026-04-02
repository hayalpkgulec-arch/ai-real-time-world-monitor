import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LiveRiskMapScreen extends StatefulWidget {
  const LiveRiskMapScreen({super.key});

  @override
  State<LiveRiskMapScreen> createState() => _LiveRiskMapScreenState();
}

class _LiveRiskMapScreenState extends State<LiveRiskMapScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String _selectedView = 'globe'; // globe | flat | heatmap

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _isLoading = progress < 1.0;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
  }

  String get _mapHTML => '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI World Monitor - Risk Map</title>
    <script src="https://unpkg.com/three@0.160.0/build/three.min.js"></script>
    <script src="https://unpkg.com/globe.gl@2.3.0/dist/globe.gl.min.js"></script>
    <style>
        body { 
            margin: 0; 
            padding: 0; 
            background: #0a0a1a; 
            overflow: hidden; 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        #globe-container { 
            width: 100vw; 
            height: 100vh; 
            position: relative;
        }
        .view-selector {
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 8px;
            background: rgba(10, 10, 26, 0.9);
            padding: 8px 16px;
            border-radius: 25px;
            border: 1px solid rgba(42, 42, 66, 0.3);
            z-index: 1000;
        }
        .view-btn {
            padding: 8px 16px;
            border: none;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            cursor: pointer;
            font-size: 13px;
            transition: all 0.3s ease;
        }
        .view-btn.active {
            background: rgba(58, 34, 138, 0.8);
        }
        .globe-tooltip {
            background: rgba(0, 0, 0, 0.9);
            color: #fff;
            padding: 12px;
            border-radius: 8px;
            font-size: 12px;
            max-width: 200px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }
        .risk-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: bold;
            margin-bottom: 4px;
        }
        .risk-critical { background: #ff1744; }
        .risk-high { background: #ff6d00; }
        .risk-elevated { background: #ffd600; }
        .risk-guarded { background: #2979ff; }
        .risk-low { background: #00e676; }
    </style>
</head>
<body>
    <div id="globe-container"></div>
    
    <div class="view-selector">
        <button class="view-btn active" onclick="setViewMode('globe')">🌍 Globe</button>
        <button class="view-btn" onclick="setViewMode('flat')">🗺️ Flat</button>
        <button class="view-btn" onclick="setViewMode('heatmap')">🔥 Heat</button>
    </div>

    <script>
        // Risk renkleri
        const RISK_COLORS = {
            CRITICAL: '#ff1744',    // Kırmızı — savaş, büyük kriz
            HIGH: '#ff6d00',     // Turuncu — yüksek risk
            ELEVATED: '#ffd600',    // Sarı — yükselen risk
            GUARDED: '#2979ff',    // Mavi — dikkat
            LOW: '#00e676',      // Yeşil — normal
        };

        // Mock veri (gerçek implementasyonda backend'den gelecek)
        const mockCountries = [
            {
                name: 'United States',
                iso3: 'USA',
                properties: {
                    riskLevel: 'HIGH',
                    riskScore: 72,
                    eventCount: 3
                }
            },
            {
                name: 'China',
                iso3: 'CHN',
                properties: {
                    riskLevel: 'ELEVATED',
                    riskScore: 58,
                    eventCount: 2
                }
            },
            {
                name: 'Russia',
                iso3: 'RUS',
                properties: {
                    riskLevel: 'CRITICAL',
                    riskScore: 85,
                    eventCount: 5
                }
            },
            {
                name: 'Iran',
                iso3: 'IRN',
                properties: {
                    riskLevel: 'CRITICAL',
                    riskScore: 91,
                    eventCount: 4
                }
            },
            {
                name: 'Israel',
                iso3: 'ISR',
                properties: {
                    riskLevel: 'HIGH',
                    riskScore: 76,
                    eventCount: 3
                }
            }
        ];

        const mockEvents = [
            {
                id: 'evt_001',
                title: 'Orta Doğu Askeri Gerilim',
                latitude: 32.4279,
                longitude: 53.6903,
                severity: 'CRITICAL',
                importance: 85,
                countries: ['IRN', 'ISR']
            },
            {
                id: 'evt_002',
                title: 'Tayvan Boğazı Artan Gerilim',
                latitude: 25.0308,
                longitude: 121.5457,
                severity: 'HIGH',
                importance: 72,
                countries: ['TWN', 'CHN']
            },
            {
                id: 'evt_003',
                title: 'Ukrayna Savunma Sevkiyesi',
                latitude: 50.4500,
                longitude: 30.5233,
                severity: 'HIGH',
                importance: 68,
                countries: ['UKR', 'RUS']
            }
        ];

        // Globe konfigürasyonu
        const world = Globe()
            .globeImageUrl('//unpkg.com/three-globe/example/img/earth-dark.jpg')
            .bumpImageUrl('//unpkg.com/three-globe/example/img/earth-topology.png')
            .backgroundImageUrl('//unpkg.com/three-globe/example/img/night-sky.png')
            .showAtmosphere(true)
            .atmosphereColor('#3a228a')
            .atmosphereAltitude(0.25)
            // Ülke poligonları (risk renkleri)
            .polygonsData(mockCountries)
            .polygonAltitude(d => d.properties.riskLevel === 'CRITICAL' ? 0.06 : 0.01)
            .polygonCapColor(d => RISK_COLORS[d.properties.riskLevel] + '90')
            .polygonSideColor(() => 'rgba(0, 100, 200, 0.15)')
            .polygonStrokeColor(() => '#111')
            .polygonLabel(d => '<div class="globe-tooltip"><h3>' + d.properties.name + '</h3><span class="risk-badge risk-' + d.properties.riskLevel.toLowerCase() + '">' + d.properties.riskLevel + '</span><p>Risk Score: ' + d.properties.riskScore + '/100</p><p>Active Events: ' + d.properties.eventCount + '</p></div>')
            // Olay noktaları (pulse efektli)
            .pointsData(mockEvents)
            .pointAltitude(0.07)
            .pointColor(d => RISK_COLORS[d.severity])
            .pointRadius(d => Math.sqrt(d.importance) * 0.05)
            .pointsMerge(false)
            // Tıklama olayları
            .onPolygonClick(handleCountryClick)
            .onPointClick(handleEventClick)
            (document.getElementById('globe-container'));

        // Otomatik döndürme
        world.controls().autoRotate = true;
        world.controls().autoRotateSpeed = 0.5;

        // Görünüm modu değiştirme
        window.setViewMode = function(mode) {
            // Buton stillerini güncelle
            document.querySelectorAll('.view-btn').forEach(function(btn) {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
            
            // Mod değiştirme logic'i buraya gelecek
            console.log('Switching to view mode:', mode);
            
            // Flutter'a mesaj gönder
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.postMessage(JSON.stringify({
                    type: 'view_mode_changed',
                    mode: mode
                }));
            }
        };

        function handleCountryClick(country) {
            console.log('Country clicked:', country);
            // Flutter'a ülke bilgisi gönder
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.postMessage(JSON.stringify({
                    type: 'country_selected',
                    country: country
                }));
            }
        }

        function handleEventClick(event) {
            console.log('Event clicked:', event);
            // Flutter'a olay bilgisi gönder
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.postMessage(JSON.stringify({
                    type: 'event_selected',
                    event: event
                }));
            }
        }

        // Flutter ile iletişim kurma
        window.flutter_inappwebview = {
            postMessage: function(data) {
                // WebView içindeki Flutter communication
                console.log('Sending to Flutter:', data);
            }
        };
    </script>
</body>
</html>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        title: const Text(
          '🗺️ LIVE RISK MAP',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          // 3D Harita WebView
          Expanded(
            child: WebViewWidget(
              onWebViewCreated: (controller) {
                _webViewController = controller;
                controller.loadHtmlString(_mapHTML);
              },
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Risk Map...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
