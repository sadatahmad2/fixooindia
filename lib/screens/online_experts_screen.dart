import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'dart:ui';

class OnlineExpertsScreen extends StatefulWidget {
  const OnlineExpertsScreen({super.key});

  @override
  State<OnlineExpertsScreen> createState() => _OnlineExpertsScreenState();
}

class _OnlineExpertsScreenState extends State<OnlineExpertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(top: -100, right: -100, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: SupabaseService.getOnlinePartnersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF00D1FF)));
                      }
                      
                      final experts = snapshot.data ?? [];
                      
                      if (experts.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      return _buildExpertsList(experts);
                    },
                  ),
                ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Experts', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Text('Active service providers near you', style: TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertsList(List<Map<String, dynamic>> experts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: experts.length,
      itemBuilder: (context, index) {
        final expert = experts[index];
        final name = expert['name'] ?? expert['full_name'] ?? 'Expert';
        final avatar = expert['avatar_url'];
        final skills = List<String>.from(expert['skills'] ?? []);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white10,
                    backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                    child: avatar == null ? const Icon(LucideIcons.user, color: Colors.white24, size: 24) : null,
                  ),
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF020408), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      skills.isEmpty ? 'General Repair Expert' : skills.join(', '),
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        const Text('4.8', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Icon(LucideIcons.mapPin, size: 12, color: const Color(0xFF00D1FF).withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text('Within 5km', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text('VIEW', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.userX, size: 60, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 20),
          const Text('No experts online right now', style: TextStyle(color: Colors.white38, fontSize: 16)),
        ],
      ),
    );
  }
}
