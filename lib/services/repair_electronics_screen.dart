import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/services/booking_screen.dart';

class RepairElectronicsScreen extends StatelessWidget {
  const RepairElectronicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'title': 'Fan Repair', 'icon': LucideIcons.wind, 'color': const Color(0xFF4FC3F7), 'price': 'From ₹149'},
      {'title': 'AC Repair', 'icon': LucideIcons.airVent, 'color': const Color(0xFF66BB6A), 'price': 'From ₹249'},
      {'title': 'Water Motor Repair', 'icon': LucideIcons.waves, 'color': const Color(0xFF29B6F6), 'price': 'From ₹149'},
      {'title': 'Water Purifier Repair', 'icon': LucideIcons.droplets, 'color': const Color(0xFF26C6DA), 'price': 'From ₹199'},
      {'title': 'TV Repair', 'icon': LucideIcons.tv, 'color': const Color(0xFFAB47BC), 'price': 'From ₹249'},
      {'title': 'Fridge Repair', 'icon': LucideIcons.snowflake, 'color': const Color(0xFF42A5F5), 'price': 'From ₹199'},
      {'title': 'Washing Machine Repair', 'icon': LucideIcons.washingMachine, 'color': const Color(0xFFEF5350), 'price': 'From ₹199'},
      {'title': 'Laptop Repair', 'icon': LucideIcons.laptop, 'color': const Color(0xFFFFB74D), 'price': 'From ₹299'},
      {'title': 'Mobile Repair', 'icon': LucideIcons.smartphone, 'color': const Color(0xFFEC407A), 'price': 'From ₹149'},
      {'title': 'Cooler Repair', 'icon': LucideIcons.wind, 'color': const Color(0xFF78909C), 'price': 'From ₹149'},
      {'title': 'Light Repair', 'icon': LucideIcons.lightbulb, 'color': const Color(0xFFFFD54F), 'price': 'From ₹99'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Repair & Electronics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select the appliance you want to repair',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final color = service['color'] as Color;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            serviceName: service['title'],
                            icon: service['icon'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.06), Colors.white.withOpacity(0.02)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(service['icon'] as IconData, color: color, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['title'] as String,
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  service['price'] as String,
                                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.15), size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
