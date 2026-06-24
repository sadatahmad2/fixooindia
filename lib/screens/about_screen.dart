import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('About FixooIndia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.white30, fontSize: 14)),
            const SizedBox(height: 40),
            Text(
              'FixooIndia is your one-stop solution for all home repair and maintenance needs. We connect you with verified expert technicians within 30 minutes, ensuring high-quality service at your doorstep.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 50),
            _buildInfoRow('Terms of Service', () {}),
            _buildInfoRow('Privacy Policy', () {}),
            _buildInfoRow('Content Policy', () {}),
            _buildInfoRow('Open Source Licenses', () {}),
            const SizedBox(height: 40),
            Text(
              'Made with ❤️ in India',
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 14),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
