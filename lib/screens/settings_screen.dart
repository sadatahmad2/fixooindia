import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/auth_screen.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;
  bool emailUpdates = false;
  bool darkMode = true;
  String selectedLanguage = 'English';

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
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(top: -100, left: -50, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
          
          SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Notifications'),
                _buildSwitchTile('Push Notifications', 'Get real-time booking updates', pushNotifications, (val) => setState(() => pushNotifications = val)),
                _buildSwitchTile('Email Updates', 'Stay updated with latest offers', emailUpdates, (val) => setState(() => emailUpdates = val)),
                
                const SizedBox(height: 35),
                _buildSectionHeader('Regional'),
                _buildLanguageTile(),
                
                const SizedBox(height: 35),
                _buildSectionHeader('Appearance'),
                _buildSwitchTile('Dark Mode', 'OLED optimized dark experience', darkMode, (val) => setState(() => darkMode = val)),
                
                const SizedBox(height: 35),
                _buildSectionHeader('Legal & Support'),
                _buildMenuTile(LucideIcons.lock, 'Privacy Policy', () => _showLegalDialog('Privacy Policy', 'Your privacy is our priority. We collect only necessary data to provide services...')),
                _buildMenuTile(LucideIcons.scrollText, 'Terms of Service', () => _showLegalDialog('Terms of Service', 'By using FixooIndia, you agree to our terms...')),
                
                const SizedBox(height: 35),
                _buildSectionHeader('Account Safety'),
                _buildMenuTile(LucideIcons.userX, 'Delete Account', () => _showDeleteConfirmation(), color: Colors.redAccent),
                
                const SizedBox(height: 50),
                Center(
                  child: Text('Version 1.0.2 (Beta)', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
                ),
                const SizedBox(height: 20),
              ],
            ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildSwitchTile(String title, String sub, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00D1FF),
        activeTrackColor: const Color(0xFF00D1FF).withOpacity(0.2),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.globe, color: Color(0xFF00D1FF), size: 18)),
        title: const Text('Language', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: DropdownButton<String>(
          value: selectedLanguage,
          dropdownColor: const Color(0xFF162436),
          underline: const SizedBox(),
          style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold),
          items: ['English', 'Hindi', 'Spanish'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: (val) => setState(() => selectedLanguage = val!),
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color.withOpacity(0.8), size: 18)),
        title: Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.1), size: 18),
        onTap: onTap,
      ),
    );
  }

  void _showLegalDialog(String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(content, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.6)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D1FF), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF162436),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('Delete Account?', style: TextStyle(color: Colors.white)),
        content: const Text('This action is permanent and cannot be undone. All your data will be wiped.', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
