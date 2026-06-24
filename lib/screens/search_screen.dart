import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/services/booking_screen.dart';
import 'dart:ui';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> allServices = [
    {'name': 'AC Service', 'category': 'Electronics', 'price': '₹599'},
    {'name': 'Full Home Wiring', 'category': 'Wiring', 'price': '₹4,999'},
    {'name': 'Full Home Cleaning', 'category': 'Cleaning', 'price': '₹1,999'},
    {'name': 'Tap Repair', 'category': 'Plumbing', 'price': '₹149'},
    {'name': 'Laptop Repair', 'category': 'Electronics', 'price': '₹799'},
    {'name': 'RO Service', 'category': 'Appliances', 'price': '₹399'},
    {'name': 'Switch Board Fix', 'category': 'Wiring', 'price': '₹149'},
  ];
  List<Map<String, dynamic>> filteredServices = [];

  @override
  void initState() {
    super.initState();
    filteredServices = [];
  }

  void _filterServices(String query) {
    if (query.isEmpty) {
      setState(() => filteredServices = []);
      return;
    }
    setState(() {
      filteredServices = allServices
          .where((s) => s['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
          
          SafeArea(
            child: Column(
              children: [
                // Search Bar Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            onChanged: _filterServices,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search for services...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                              border: InputBorder.none,
                              prefixIcon: Icon(LucideIcons.search, color: const Color(0xFF00D1FF).withOpacity(0.5), size: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Results
                Expanded(
                  child: filteredServices.isEmpty && _controller.text.isNotEmpty
                  ? _buildNoResults()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        return _buildSearchResultCard(service);
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

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.searchX, size: 50, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 15),
          const Text('No services found', style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.wrench, color: Color(0xFF00D1FF), size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(service['category'], style: TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
          Text(service['price'], style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          IconButton(
            icon: const Icon(LucideIcons.arrowRight, color: Colors.white10, size: 18),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(serviceName: service['name'], icon: LucideIcons.wrench)));
            },
          ),
        ],
      ),
    );
  }
}
