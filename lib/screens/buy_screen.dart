import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'AC', 'Fan', 'Cooler', 'TV', 'Fridge', 'Washing Machine', 'Water Purifier', 'Light'];

  final List<Map<String, dynamic>> products = [
    {'name': 'Split AC 1.5 Ton', 'brand': 'Voltas', 'price': '₹32,990', 'oldPrice': '₹38,990', 'category': 'AC', 'rating': 4.3, 'icon': LucideIcons.airVent},
    {'name': 'Inverter AC 1 Ton', 'brand': 'Daikin', 'price': '₹29,490', 'oldPrice': '₹35,000', 'category': 'AC', 'rating': 4.5, 'icon': LucideIcons.airVent},
    {'name': 'Window AC 1.5 Ton', 'brand': 'LG', 'price': '₹26,990', 'oldPrice': '₹31,000', 'category': 'AC', 'rating': 4.2, 'icon': LucideIcons.airVent},
    {'name': 'Ceiling Fan 1200mm', 'brand': 'Havells', 'price': '₹1,899', 'oldPrice': '₹2,499', 'category': 'Fan', 'rating': 4.4, 'icon': LucideIcons.wind},
    {'name': 'BLDC Fan 1200mm', 'brand': 'Orient', 'price': '₹3,499', 'oldPrice': '₹4,299', 'category': 'Fan', 'rating': 4.6, 'icon': LucideIcons.wind},
    {'name': 'Exhaust Fan 12"', 'brand': 'Crompton', 'price': '₹1,099', 'oldPrice': '₹1,399', 'category': 'Fan', 'rating': 4.1, 'icon': LucideIcons.wind},
    {'name': 'Desert Cooler 70L', 'brand': 'Symphony', 'price': '₹9,990', 'oldPrice': '₹12,999', 'category': 'Cooler', 'rating': 4.2, 'icon': LucideIcons.wind},
    {'name': 'Tower Cooler 55L', 'brand': 'Bajaj', 'price': '₹7,490', 'oldPrice': '₹9,999', 'category': 'Cooler', 'rating': 4.0, 'icon': LucideIcons.wind},
    {'name': 'Smart TV 43" 4K', 'brand': 'Mi', 'price': '₹24,999', 'oldPrice': '₹31,999', 'category': 'TV', 'rating': 4.4, 'icon': LucideIcons.tv},
    {'name': 'LED TV 32" HD', 'brand': 'Samsung', 'price': '₹13,490', 'oldPrice': '₹17,990', 'category': 'TV', 'rating': 4.3, 'icon': LucideIcons.tv},
    {'name': 'OLED TV 55"', 'brand': 'LG', 'price': '₹89,990', 'oldPrice': '₹1,09,990', 'category': 'TV', 'rating': 4.7, 'icon': LucideIcons.tv},
    {'name': 'Double Door 260L', 'brand': 'Samsung', 'price': '₹23,990', 'oldPrice': '₹28,990', 'category': 'Fridge', 'rating': 4.4, 'icon': LucideIcons.snowflake},
    {'name': 'Single Door 190L', 'brand': 'LG', 'price': '₹14,490', 'oldPrice': '₹17,990', 'category': 'Fridge', 'rating': 4.3, 'icon': LucideIcons.snowflake},
    {'name': 'Front Load 7kg', 'brand': 'IFB', 'price': '₹27,990', 'oldPrice': '₹34,990', 'category': 'Washing Machine', 'rating': 4.5, 'icon': LucideIcons.washingMachine},
    {'name': 'Top Load 8kg', 'brand': 'Whirlpool', 'price': '₹16,990', 'oldPrice': '₹20,990', 'category': 'Washing Machine', 'rating': 4.2, 'icon': LucideIcons.washingMachine},
    {'name': 'RO + UV Purifier', 'brand': 'Kent', 'price': '₹15,499', 'oldPrice': '₹19,999', 'category': 'Water Purifier', 'rating': 4.3, 'icon': LucideIcons.droplets},
    {'name': 'RO Purifier 8L', 'brand': 'Aquaguard', 'price': '₹12,999', 'oldPrice': '₹16,999', 'category': 'Water Purifier', 'rating': 4.1, 'icon': LucideIcons.droplets},
    {'name': 'LED Bulb 12W (Pack 6)', 'brand': 'Philips', 'price': '₹549', 'oldPrice': '₹799', 'category': 'Light', 'rating': 4.5, 'icon': LucideIcons.lightbulb},
    {'name': 'Tube Light 20W', 'brand': 'Syska', 'price': '₹349', 'oldPrice': '₹499', 'category': 'Light', 'rating': 4.2, 'icon': LucideIcons.lightbulb},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == 'All'
        ? products
        : products.where((p) => p['category'] == selectedCategory).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, color: Colors.white30, size: 20),
                  const SizedBox(width: 12),
                  Text('Search products...', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Deal Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(LucideIcons.shoppingBag, size: 80, color: Colors.white.withOpacity(0.08)),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🔥 Summer Sale', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('Buy + Free Installation on AC, Fan & Cooler', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 10),
                      Text('Up to 40% OFF', style: TextStyle(color: Colors.yellowAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Category Chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = selectedCategory == categories[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = categories[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF0D1B2E) : Colors.white54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Products Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              selectedCategory == 'All' ? 'All Products' : '$selectedCategory',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Buy + Get Free Installation',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
          ),
          const SizedBox(height: 15),

          // Product Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final product = filtered[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Area
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(product['icon'] as IconData, size: 50, color: const Color(0xFF00D1FF).withOpacity(0.3)),
                            ),
                            // Rating Badge
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 12, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text('${product['rating']}', style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            // Free Install Badge
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Free Install', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Product Details
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['brand'] as String,
                              style: TextStyle(color: const Color(0xFF00D1FF).withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              product['name'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  product['price'] as String,
                                  style: const TextStyle(color: Color(0xFF00D1FF), fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  product['oldPrice'] as String,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.25),
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Processing purchase for ${product['name']}...'),
                                      backgroundColor: const Color(0xFF00D1FF),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                  Future.delayed(const Duration(seconds: 1), () {
                                    if (mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: const Color(0xFF162436),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                          title: const Text('Order Placed!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          content: Text('Your ${product['name']} has been ordered successfully. Free installation is scheduled.', style: const TextStyle(color: Colors.white54)),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('AWESOME', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D1FF).withOpacity(0.1),
                                  foregroundColor: const Color(0xFF00D1FF),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text('Buy Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
