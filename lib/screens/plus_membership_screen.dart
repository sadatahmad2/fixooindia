import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/services/payment_service.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'package:fixoo/widgets/pro_success_animation.dart';
import 'package:fixoo/home_screen.dart';

class PlusMembershipScreen extends StatefulWidget {
  const PlusMembershipScreen({super.key});

  @override
  State<PlusMembershipScreen> createState() => _PlusMembershipScreenState();
}

class _PlusMembershipScreenState extends State<PlusMembershipScreen> {
  int selectedPlanIndex = 1; // Default to Pro (Middle)

  @override
  void initState() {
    super.initState();
    PaymentService.initialize(context);
  }

  @override
  void dispose() {
    PaymentService.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Basic',
      'period': '1 Month',
      'price': '199',
      'discount': '10% Off',
      'color': const Color(0xFF00D1FF),
      'benefits': [
        {'icon': LucideIcons.percent, 'title': 'Extra 10% Discount', 'sub': 'On every service you book'},
        {'icon': LucideIcons.zap, 'title': 'Standard Support', 'sub': 'Technician within 60 mins'},
      ]
    },
    {
      'name': 'Pro',
      'period': '6 Months',
      'price': '999',
      'discount': '20% Off',
      'color': const Color(0xFFFFD700),
      'popular': true,
      'benefits': [
        {'icon': LucideIcons.percent, 'title': 'Extra 20% Discount', 'sub': 'On every service you book'},
        {'icon': LucideIcons.zap, 'title': 'Priority Support', 'sub': 'Technician within 30 mins'},
        {'icon': LucideIcons.shield, 'title': 'Extended Warranty', 'sub': '60 days extra protection'},
      ]
    },
    {
      'name': 'Ultra',
      'period': '12 Months',
      'price': '1799',
      'discount': '35% Off',
      'color': const Color(0xFFFF4D4D),
      'benefits': [
        {'icon': LucideIcons.percent, 'title': 'Extra 35% Discount', 'sub': 'On every service you book'},
        {'icon': LucideIcons.zap, 'title': 'Ultra Fast Support', 'sub': 'Technician within 15 mins'},
        {'icon': LucideIcons.shield, 'title': 'Extended Warranty', 'sub': '180 days extra protection'},
        {'icon': LucideIcons.crown, 'title': 'VIP Badge', 'sub': 'Recognized as a premium member'},
      ]
    },
  ];

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
        title: const Text('FixooIndia Plus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your plan',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Save more with our premium memberships',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
            ),
            const SizedBox(height: 25),

            // Plan Cards Row
            Row(
              children: List.generate(plans.length, (index) {
                final plan = plans[index];
                final isSelected = selectedPlanIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedPlanIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 10),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? plan['color'].withOpacity(0.15) : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? plan['color'] : Colors.white.withOpacity(0.05),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (plan['popular'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: plan['color'], borderRadius: BorderRadius.circular(10)),
                              child: const Text('POPULAR', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          Text(plan['name'], style: TextStyle(color: isSelected ? plan['color'] : Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('₹', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              Text(plan['price'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(plan['period'], style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 35),
            
            // Benefits List
            const Text('Exclusive Benefits', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            ... (plans[selectedPlanIndex]['benefits'] as List).map((benefit) => _buildBenefit(
              benefit['icon'], 
              benefit['title'], 
              benefit['sub'], 
              plans[selectedPlanIndex]['color']
            )),
            
            const SizedBox(height: 30),
            
            // Buy Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _showPurchaseDialog(plans[selectedPlanIndex]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: plans[selectedPlanIndex]['color'],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: plans[selectedPlanIndex]['color'].withOpacity(0.4),
                ),
                child: Text('Get ${plans[selectedPlanIndex]['name']} Plus', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String sub, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF162436),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 25),
            Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 15),
            Text('Upgrade to ${plan['name']} Plus', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('You will be charged ₹${plan['price']} for ${plan['period']} membership.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx); // Close BottomSheet
                  bool success = await PaymentService.processPayment(
                    context,
                    amount: double.parse(plan['price']),
                    description: '${plan['name']} Plus Membership',
                  );
                  
                  if (success && mounted) {
                    try {
                      // Update membership in database
                      await SupabaseService.updateMembership(plan['name']);
                    } catch (e) {
                      debugPrint('Error updating membership: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment Success, but DB Update Failed: $e'), backgroundColor: Colors.orange),
                        );
                      }
                    }
                    
                    if (!mounted) return;

                    // Play Cinematic Animation
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => ProSuccessAnimation(
                        onFinished: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: plan['color'], foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('Confirm & Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
