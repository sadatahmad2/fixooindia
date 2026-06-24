import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/screens/edit_profile_screen.dart';
import 'package:fixoo/screens/bookings_screen.dart';
import 'package:fixoo/screens/help_support_screen.dart';
import 'package:fixoo/screens/wallet_screen.dart';
import 'package:fixoo/screens/plus_membership_screen.dart';
import 'package:fixoo/screens/my_rating_screen.dart';
import 'package:fixoo/screens/manage_addresses_screen.dart';
import 'package:fixoo/screens/payment_methods_screen.dart';
import 'package:fixoo/screens/refer_earn_screen.dart';
import 'package:fixoo/screens/settings_screen.dart';
import 'package:fixoo/screens/about_screen.dart';
import 'package:fixoo/screens/active_plan_screen.dart';
import 'package:fixoo/auth_screen.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'dart:io';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'User Name';
  String userPhone = '+91 00000 00000';
  String userEmail = 'user@example.com';
  String? userAvatar;
  double walletBalance = 0.0;
  bool isPlusMember = false;
  String? membershipType;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadWallet();
  }

  Future<void> _loadProfile() async {
    final user = SupabaseService.currentUser;
    final profile = await SupabaseService.getProfile();
    if (mounted) {
      setState(() {
        if (user != null) userPhone = user.phone ?? userPhone;
        if (profile != null) {
          userName = profile['full_name'] ?? profile['name'] ?? userName;
          userPhone = profile['phone'] ?? userPhone;
          userEmail = profile['email'] ?? userEmail;
          userAvatar = profile['avatar_url'];
          isPlusMember = profile['is_plus_member'] == true;
          membershipType = (profile['membership_type'] as String?) ?? 'Plus';
        }
      });
    }
  }

  Future<void> _loadWallet() async {
    final balance = await SupabaseService.getWalletBalance();
    if (mounted) setState(() => walletBalance = balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // Background Glow
          Positioned(top: -100, right: -100, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Profile Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      currentName: userName,
                                      currentEmail: userEmail,
                                      currentPhone: userPhone,
                                      currentAvatar: userAvatar,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadProfile();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D1FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(LucideIcons.pencil, color: Color(0xFF00D1FF), size: 16),
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF00D1FF),
                          backgroundImage: userAvatar != null 
                              ? (userAvatar!.startsWith('http') 
                                  ? NetworkImage(userAvatar!) 
                                  : FileImage(File(userAvatar!)) as ImageProvider)
                              : null,
                          child: userAvatar == null 
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                                ) 
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(userPhone, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(userEmail, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            _buildHeaderStat('Wallet', '₹${walletBalance.toInt()}'),
                            const SizedBox(width: 15),
                            _buildHeaderStat('Rating', '5.0 ★'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Menu Section
                  _buildSection('Services', [
                    if (isPlusMember)
                      _buildListTile(
                        context, 
                        LucideIcons.gem, 
                        'My Plan', 
                        ActivePlanScreen(planName: membershipType ?? 'Plus'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Text('ACTIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    _buildListTile(context, LucideIcons.shieldCheck, isPlusMember ? 'Upgrade Plan' : 'Plus Membership', const PlusMembershipScreen()),
                    _buildListTile(context, LucideIcons.wallet, 'Wallet History', const WalletScreen()),
                  ]),
                  
                  const SizedBox(height: 25),
                  
                  _buildSection('Account Settings', [
                    _buildListTile(context, LucideIcons.mapPin, 'Manage Addresses', const ManageAddressesScreen()),
                    _buildListTile(context, LucideIcons.creditCard, 'Payment Methods', const PaymentMethodsScreen()),
                    _buildListTile(context, LucideIcons.settings, 'Preferences', const SettingsScreen()),
                  ]),
                  
                  const SizedBox(height: 25),
                  
                  _buildSection('More', [
                    _buildListTile(context, LucideIcons.gift, 'Refer & Earn', const ReferEarnScreen()),
                    _buildListTile(context, LucideIcons.headset, 'Help & Support', const HelpSupportScreen()),
                    _buildListTile(context, LucideIcons.info, 'About FixooIndia', const AboutScreen()),
                  ]),

                  const SizedBox(height: 35),
                  
                  // Logout
                  GestureDetector(
                    onTap: () async {
                      await SupabaseService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                      ),
                      child: const Center(
                        child: Text('Logout Account', style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
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

  Widget _buildHeaderStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 15),
          child: Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, Widget screen, {Widget? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF00D1FF).withOpacity(0.8), size: 18),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.1), size: 18),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
  }
}
