import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyRatingScreen extends StatelessWidget {
  const MyRatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('My Rating', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Rating Score
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  const Text('Your Rating', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 10),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]).createShader(bounds),
                    child: const Text('5.0', style: TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(Icons.star, color: Color(0xFFFFD700), size: 28),
                    )),
                  ),
                  const SizedBox(height: 12),
                  Text('Based on 0 services', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Rating Breakdown', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            _buildRatingBar('5 Star', 1.0, Colors.greenAccent),
            _buildRatingBar('4 Star', 0.0, Colors.green),
            _buildRatingBar('3 Star', 0.0, Colors.amber),
            _buildRatingBar('2 Star', 0.0, Colors.orange),
            _buildRatingBar('1 Star', 0.0, Colors.redAccent),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00D1FF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, color: Color(0xFF00D1FF), size: 18),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Maintain a high rating to get priority service & discounts', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 55, child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13))),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: value, backgroundColor: Colors.white.withOpacity(0.05), color: color, minHeight: 8),
            ),
          ),
        ],
      ),
    );
  }
}
