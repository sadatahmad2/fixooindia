import 'package:flutter/material.dart';
import 'package:fixoo/services/booking_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';

class ServiceListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> services;

  const ServiceListScreen({
    super.key,
    required this.title,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -50, right: -50, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
          Positioned(bottom: -100, left: -50, child: _buildGlow(const Color(0xFF00D1FF), 0.03)),
          
          services.isEmpty 
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceGridCard(context, service);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double opacity) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(opacity)),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.construction, size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text('Coming Soon...', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildServiceGridCard(BuildContext context, Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingScreen(
              serviceName: service['name'],
              icon: _getIconForCategory(title),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00D1FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconForCategory(title), color: const Color(0xFF00D1FF), size: 28),
            ),
            const SizedBox(height: 15),
            Text(
              service['name'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              service['price'],
              style: TextStyle(color: const Color(0xFF00D1FF).withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Text(
              'BOOK NOW',
              style: TextStyle(color: Color(0xFF00D1FF), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String title) {
    if (title.contains('Wiring')) return LucideIcons.cable;
    if (title.contains('Plumbing')) return LucideIcons.pipette;
    if (title.contains('Electrical')) return LucideIcons.zap;
    return LucideIcons.wrench;
  }
}
