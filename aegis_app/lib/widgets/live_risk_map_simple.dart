import 'package:flutter/material.dart';

class LiveRiskMapScreen extends StatelessWidget {
  const LiveRiskMapScreen({super.key});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.public,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            const Text(
              '🌍 3D RISK MAP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  _buildFeatureItem('🌍 Interactive 3D Globe'),
                  const SizedBox(height: 10),
                  _buildFeatureItem('🔥 Real-time Risk Heatmap'),
                  const SizedBox(height: 10),
                  _buildFeatureItem('📍 Event Points & Connections'),
                  const SizedBox(height: 10),
                  _buildFeatureItem('📊 Country Risk Scores'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 16,
          color: Colors.green,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
