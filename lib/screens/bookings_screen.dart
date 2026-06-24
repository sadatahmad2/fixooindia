import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fixoo/providers/booking_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:fixoo/screens/booking_detail_screen.dart';
import 'package:fixoo/screens/tracking_screen.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'dart:ui';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  final _bookingsStream = SupabaseService.client
      .from('bookings')
      .stream(primaryKey: ['id'])
      .eq('user_id', SupabaseService.currentUser?.id ?? '')
      .order('created_at', ascending: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: const Text('My Bookings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(bottom: -100, left: -100, child: _buildGlow(const Color(0xFF00D1FF), 0.03)),
          
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _bookingsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00D1FF)));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final bookings = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = Booking.fromMap(bookings[index]);
                  return _buildLuxuryBookingCard(booking);
                },
              );
            },
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

  Widget _buildLuxuryBookingCard(Booking booking) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailScreen(booking: booking)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(LucideIcons.wrench, color: Color(0xFF00D1FF), size: 18),
                      ),
                      _buildStatusBadge(booking.status),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(booking.serviceName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(booking.brand, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoItem(LucideIcons.calendar, booking.date),
                      const SizedBox(width: 20),
                      _buildInfoItem(LucideIcons.clock, DateFormat('hh:mm a').format(booking.bookingTime)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => TrackingScreen(
                      serviceName: booking.serviceName,
                      brand: booking.brand,
                      technicianName: booking.partnerName,
                      technicianAvatar: booking.partnerAvatar,
                      partnerId: booking.partnerId,
                      bookingId: booking.id,
                    )
                  )
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D1FF).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.mapPin, color: Color(0xFF00D1FF), size: 16),
                    const SizedBox(width: 10),
                    const Text('Technician Live Location', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 13, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Icon(Icons.arrow_forward, color: const Color(0xFF00D1FF).withOpacity(0.5), size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.2)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = const Color(0xFF00D1FF);
    if (status == 'Pending') color = Colors.amber;
    if (status == 'Completed') color = Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle),
            child: Icon(LucideIcons.calendarX2, size: 60, color: Colors.white.withOpacity(0.08)),
          ),
          const SizedBox(height: 25),
          const Text('No bookings yet', style: TextStyle(color: Colors.white24, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
