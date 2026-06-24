import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/providers/notification_provider.dart';
import 'package:fixoo/services/repair_electronics_screen.dart';
import 'package:fixoo/services/service_list_screen.dart';
import 'package:fixoo/screens/bookings_screen.dart';
import 'package:fixoo/screens/profile_screen.dart';
import 'package:fixoo/screens/notifications_screen.dart';
import 'package:fixoo/screens/plus_membership_screen.dart';
import 'package:fixoo/screens/search_screen.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'package:fixoo/screens/online_experts_screen.dart';
import 'dart:ui';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _glowController;

  final List<Widget> _screens = [
    const HomeContent(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    
    // Initialize real-time notifications
    final user = SupabaseService.currentUser;
    if (user != null) {
      Provider.of<NotificationProvider>(context, listen: false).initRealtime(user.id);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      extendBody: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) => Stack(
              children: [
                Positioned(top: -150, right: -100, child: _buildGlowCircle(const Color(0xFF00D1FF), 0.08, 400)),
                Positioned(bottom: -100, left: -50, child: _buildGlowCircle(const Color(0xFF0077FF), 0.05, 350)),
              ],
            ),
          ),
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: _buildFloatingBottomNav(),
    );
  }

  Widget _buildGlowCircle(Color color, double opacity, double size) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(opacity)), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container()));
  }

  Widget _buildFloatingBottomNav() {
    return Container(
      height: 75, margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 15))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(30), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildNavItem(0, LucideIcons.house, 'Home'), _buildNavItem(1, LucideIcons.clipboardList, 'Bookings'), _buildNavItem(2, LucideIcons.user, 'Account')]))),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF00D1FF).withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: isSelected ? const Color(0xFF00D1FF) : Colors.white24, size: 22), const SizedBox(height: 4), Text(label, style: TextStyle(color: isSelected ? const Color(0xFF00D1FF) : Colors.white24, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))]),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String userName = 'FixooIndia Member';
  String? avatarUrl;
  String? membershipType;
  int onlinePartnersCount = 0;
  List<Map<String, dynamic>> onlinePartners = [];
  Timer? _onlineTimer;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchOnlinePartners();
    _onlineTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchOnlinePartners();
    });
  }

  Future<void> _fetchOnlinePartners() async {
    final list = await SupabaseService.getOnlinePartners();
    if (mounted) {
      setState(() {
        onlinePartners = list;
        onlinePartnersCount = list.length;
      });
    }
  }

  Future<void> _loadProfile() async {
    final profile = await SupabaseService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        userName = profile['full_name'] ?? profile['name'] ?? 'FixooIndia Member';
        avatarUrl = profile['avatar_url'];
        membershipType = (profile['is_plus_member'] == true) ? 'Plus' : null;
      });
    }
  }
  @override
  void dispose() {
    _onlineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Image.asset('assets/images/logo.png', width: 40, height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2), // Space for the gold border
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: membershipType != null 
                              ? Border.all(color: const Color(0xFFFFD700), width: 2)
                              : Border.all(color: Colors.transparent, width: 2),
                            boxShadow: membershipType != null ? [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                            ] : null,
                          ),
                          child: CircleAvatar(
                            radius: 22, // Adjusted for padding
                            backgroundColor: Colors.white10, 
                            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                            child: avatarUrl == null ? const Icon(LucideIcons.user, color: Color(0xFF00D1FF), size: 20) : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Welcome back,', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)), 
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      userName, 
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  if (membershipType != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'PLUS',
                                        style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildLiveExpertIcon(context),
                const SizedBox(width: 10),
                _buildHeaderIcon(context, LucideIcons.bell, true),
              ],
            ),

            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: Container(
                height: 60, padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, color: Color(0xFF00D1FF), size: 20),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Search for Repair Services...', 
                        style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(LucideIcons.slidersHorizontal, color: Colors.white.withOpacity(0.2), size: 18)
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Text('PRIMARY REPAIR SERVICES', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 1.1,
              children: [
                _buildPremiumCard(context, 'Electronics Repair', LucideIcons.tv, const Color(0xFF00D1FF), () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const RepairElectronicsScreen()));
                }),
                _buildPremiumCard(context, 'Wiring Repair', LucideIcons.cable, const Color(0xFFFFD700), () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen(
                     title: 'Wiring Repair',
                     services: [
                       {'name': 'Full Home Wiring', 'image': '', 'price': '₹4,999'},
                       {'name': 'MCB/Fuse Change', 'image': '', 'price': '₹249'},
                       {'name': 'Internal Wire Fault', 'image': '', 'price': '₹599'},
                       {'name': 'Switch Board Fix', 'image': '', 'price': '₹149'},
                     ],
                   )));
                }),
                _buildPremiumCard(context, 'Plumbing Repair', LucideIcons.pipette, const Color(0xFF0077FF), () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen(
                     title: 'Plumbing Repair',
                     services: [
                       {'name': 'Full Plumbing', 'image': '', 'price': '₹7,999'},
                       {'name': 'New Pipe Fitting', 'image': '', 'price': '₹899'},
                       {'name': 'Tap Repair', 'image': '', 'price': '₹199'},
                       {'name': 'Drainage Clearing', 'image': '', 'price': '₹449'},
                     ],
                   )));
                }),
                 _buildPremiumCard(context, 'Home Cleaning', LucideIcons.sparkles, const Color(0xFFE040FB), () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen(
                     title: 'Home Cleaning',
                     services: [
                       {'name': 'Full Home Cleaning', 'image': '', 'price': '₹1,999'},
                       {'name': 'Kitchen Cleaning', 'image': '', 'price': '₹599'},
                       {'name': 'Bathroom Cleaning', 'image': '', 'price': '₹399'},
                       {'name': 'Room Cleaning', 'image': '', 'price': '₹499'},
                     ],
                   )));
                 }),
                 _buildPremiumCard(context, 'Carpentry Repair', LucideIcons.hammer, const Color(0xFFFF5722), () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen(
                     title: 'Carpentry Repair',
                     services: [
                       {'name': 'Door Repair & Fitting', 'image': '', 'price': '₹299'},
                       {'name': 'Lock & Handle Installation', 'image': '', 'price': '₹149'},
                       {'name': 'Furniture Assembly/Repair', 'image': '', 'price': '₹799'},
                       {'name': 'Bed/Sofa Repair', 'image': '', 'price': '₹899'},
                       {'name': 'Wardrobe/Cabinet Repair', 'image': '', 'price': '₹599'},
                       {'name': 'Kitchen Drawer Fix', 'image': '', 'price': '₹199'},
                       {'name': 'Wood Polishing & Finish', 'image': '', 'price': '₹1,499'},
                       {'name': 'Custom Furniture Making', 'image': '', 'price': '₹9,999'},
                     ],
                   )));
                 }),
                 _buildPremiumCard(context, 'Interior Design', LucideIcons.house, const Color(0xFF4CAF50), () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen(
                     title: 'Interior Design',
                     services: [
                       {'name': 'Modular Kitchen Design', 'image': '', 'price': '₹45,000'},
                       {'name': 'False Ceiling (POP/PVC)', 'image': '', 'price': '₹4,999'},
                       {'name': 'Wallpaper Installation', 'image': '', 'price': '₹1,199'},
                       {'name': 'PVC Wall Panel Fitting', 'image': '', 'price': '₹2,499'},
                       {'name': 'TV Unit & Wardrobe Design', 'image': '', 'price': '₹15,000'},
                       {'name': 'Wooden/Laminate Flooring', 'image': '', 'price': '₹5,999'},
                       {'name': 'Lighting & Decoration', 'image': '', 'price': '₹2,999'},
                       {'name': 'Full Home Interior', 'image': '', 'price': '₹99,000'},
                     ],
                   )));
                 }),
                 _buildPremiumCard(context, 'Professional Painting', LucideIcons.paintRoller, const Color(0xFFF44336), () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen(
                     title: 'Professional Painting',
                     services: [
                       {'name': 'Full House Painting (Int)', 'image': '', 'price': '₹8,999'},
                       {'name': 'Exterior Wall Painting', 'image': '', 'price': '₹12,999'},
                       {'name': 'Single Room Painting', 'image': '', 'price': '₹2,499'},
                       {'name': 'Texture & Stencil Design', 'image': '', 'price': '₹1,999'},
                       {'name': 'Waterproofing Treatment', 'image': '', 'price': '₹3,499'},
                       {'name': 'Putty & Primer Work', 'image': '', 'price': '₹999'},
                       {'name': 'Door & Window Polishing', 'image': '', 'price': '₹799'},
                       {'name': 'Metal/Gate Painting', 'image': '', 'price': '₹1,199'},
                     ],
                   )));
                 }),
              ],
            ),

            const SizedBox(height: 40),
            if (membershipType == null) 
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlusMembershipScreen())),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.05), blurRadius: 20, spreadRadius: 5)]),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            const Text(
                              'PLUS EXCLUSIVE', 
                              style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                            ), 
                            const SizedBox(height: 10), 
                            const Text(
                              'Enjoy Priority\nService & Rewards', 
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)
                            ), 
                            const SizedBox(height: 15), 
                            const Text(
                              'Get Plus Membership', 
                              style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)
                            )
                          ]
                        )
                      ), 
                      const Icon(
                        LucideIcons.crown, 
                        color: Color(0xFFFFD700), 
                        size: 60
                      )
                    ]
                  ),
                ),
              ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveExpertIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineExpertsScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00D1FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                const Icon(LucideIcons.radar, color: Color(0xFF00D1FF), size: 18),
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
            if (onlinePartnersCount > 0) ...[
              const SizedBox(width: 8),
              Text(
                onlinePartnersCount.toString(),
                style: const TextStyle(color: Color(0xFF00D1FF), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon, bool hasNotification) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Stack(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (hasNotification)
              const Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(radius: 4, backgroundColor: Color(0xFF00D1FF)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 15, spreadRadius: 0)]),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Container(
              padding: const EdgeInsets.all(18), 
              decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.1))), 
              child: Icon(icon, color: color, size: 24),
            ), 
            const SizedBox(height: 12), 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title, 
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), 
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
