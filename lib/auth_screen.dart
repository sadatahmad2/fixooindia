import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fixoo/otp_screen.dart';
import 'package:fixoo/register_screen.dart';
import 'package:fixoo/home_screen.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'dart:ui';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040C18),
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
          Positioned(bottom: -150, right: -50, child: _buildGlow(const Color(0xFF0FF4C6), 0.03)),
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),
                          Center(
                            child: Image.asset(
                              'assets/images/logo.png', 
                              width: 120, 
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'Premium\nHome Services',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Enter your mobile number to begin',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 50),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                              decoration: const InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 20, right: 15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('+91', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 17, fontWeight: FontWeight.w900)),
                                      SizedBox(width: 10),
                                      VerticalDivider(color: Colors.white12, indent: 18, endIndent: 18, width: 1),
                                    ],
                                  ),
                                ),
                                hintText: 'Mobile Number',
                                hintStyle: TextStyle(color: Colors.white12),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Container(
                            width: double.infinity,
                            height: 65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00D1FF).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_phoneController.text.length == 10) {
                                  final fullPhone = '+91${_phoneController.text}';
                                  SupabaseService.sendOTP(fullPhone);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OTPScreen(phoneNumber: fullPhone)));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 10-digit number')));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D1FF),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                elevation: 0,
                              ),
                              child: const Text('Get Started', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text('QUICK LOGIN', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                              ),
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              _buildSocialButton(FontAwesomeIcons.google, () async {
                                if (_isGoogleLoading) return;
                                setState(() => _isGoogleLoading = true);
                                try {
                                  final result = await SupabaseService.signInWithGoogle();
                                  if (result != null && mounted) {
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                                  }
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Login Failed: ${e.toString().replaceAll('Exception:', '').trim()}')));
                                } finally {
                                  if (mounted) setState(() => _isGoogleLoading = false);
                                }
                              }, isLoading: _isGoogleLoading),
                              const SizedBox(width: 15),
                              _buildSocialButton(FontAwesomeIcons.apple, () {}),
                            ],
                          ),
                          const Spacer(),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                              child: RichText(
                                text: TextSpan(
                                  text: "New to FixooIndia? ",
                                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                                  children: const [
                                    TextSpan(text: 'Create Account', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double opacity) {
    return Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(opacity)), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: Container()));
  }

  Widget _buildSocialButton(dynamic icon, VoidCallback onTap, {bool isLoading = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00D1FF)))
                : FaIcon(icon, color: Colors.white.withOpacity(0.8), size: 22),
          ),
        ),
      ),
    );
  }
}
