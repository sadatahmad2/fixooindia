import 'package:flutter/material.dart';
import 'package:fixoo/providers/booking_provider.dart';
import 'package:fixoo/screens/tracking_screen.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'package:fixoo/services/pdf_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Booking _booking;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await SupabaseService.updatePaymentStatus(_booking.id!, 'Paid', response.paymentId ?? '');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  void _startPayment({double? customAmount, bool isAdvance = false}) {
    final amount = customAmount ?? _booking.price;
    if (amount == null || amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid payment amount'), backgroundColor: Colors.orange));
      return;
    }

    var options = {
      'key': 'rzp_test_SifkAZASCn3YXX', 
      'amount': (amount * 100).toInt(),
      'name': 'FixooIndia Services',
      'description': isAdvance ? 'Advance for ${_booking.serviceName}' : 'Payment for ${_booking.serviceName}',
      'prefill': {
        'contact': SupabaseService.currentUser?.phone ?? '',
        'email': SupabaseService.currentUser?.email ?? '',
      },
      'notes': {
        'booking_id': _booking.id,
        'type': isAdvance ? 'advance' : 'full'
      }
    };

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
      if (isAdvance) {
        await SupabaseService.client.from('bookings').update({
          'advance_status': 'paid',
          'advance_amount': amount,
        }).eq('id', _booking.id!);
      } else {
        await SupabaseService.updatePaymentStatus(_booking.id!, 'paid', response.paymentId ?? '');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green));
      }
    });

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _updateApproval(String status) async {
    await SupabaseService.client.from('bookings').update({
      'approval_status': status,
    }).eq('id', _booking.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quote $status'), backgroundColor: status == 'approved' ? Colors.green : Colors.red));
    }
  }

  void _makeCall(String? partnerId) async {
    final Uri launchUri = Uri(scheme: 'tel', path: '918084886252'); 
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService.client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('id', _booking.id ?? '')
          .limit(1),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          _booking = Booking.fromMap(snapshot.data!.first);
        }
        
        return Scaffold(
          backgroundColor: const Color(0xFF030712),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Booking Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          ),
          body: Stack(
            children: [
              Positioned(top: -100, right: -100, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
              
              SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.wrench, color: Color(0xFF00D1FF), size: 24),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_booking.serviceName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(_booking.brand, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
                              ],
                            ),
                          ),
                          _buildStatusBadge(_booking.status),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    const Text('SERVICE TIMELINE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 25),
                    
                    // Live Timeline
                    _buildTimelineItem('Booking Confirmed', 'We have received your request', 'Done', true, true),
                    _buildTimelineItem(
                      'Technician Assigned', 
                      _booking.partnerName != null ? '${_booking.partnerName} is on the way' : 'Finding the best technician for you', 
                      _booking.partnerName != null ? 'Done' : '--:--', 
                      _booking.partnerName != null, 
                      true,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // PROMINENT APPROVAL ACTION CARD
                    if (_booking.approvalStatus?.toLowerCase() == 'pending')
                      Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [const Color(0xFF00D1FF).withOpacity(0.15), const Color(0xFF0066FF).withOpacity(0.05)]),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.3), width: 2),
                          boxShadow: [BoxShadow(color: const Color(0xFF00D1FF).withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.listTodo, color: Color(0xFF00D1FF), size: 24),
                                SizedBox(width: 12),
                                Text('QUOTE APPROVAL REQUIRED', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Technician has sent a quote of ₹${double.tryParse(_booking.price?.toString() ?? '0') ?? 0.0}. Please review and approve to start work.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5)),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: _buildActionButton('REJECT', Colors.redAccent, () => _updateApproval('rejected'))),
                                const SizedBox(width: 15),
                                Expanded(child: _buildActionButton('APPROVE', Colors.greenAccent, () => _updateApproval('approved'))),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (_booking.status == 'Cancelled')
                      _buildTimelineItem('Booking Cancelled', 'The service request was cancelled', 'Now', true, false)
                    else ...[
                      _buildTimelineItem(
                        'Technician Arrived', 
                        _booking.status == 'Arrived' || _booking.status == 'In Progress' || _booking.status == 'Completed' ? 'Technician has reached' : 'Technician is travelling', 
                        _booking.status == 'Arrived' || _booking.status == 'In Progress' || _booking.status == 'Completed' ? 'Done' : '--:--', 
                        _booking.status == 'Arrived' || _booking.status == 'In Progress' || _booking.status == 'Completed', 
                        true
                      ),
                      _buildTimelineItem(
                        'Work in Progress', 
                        _booking.status == 'In Progress' || _booking.status == 'Completed' ? 'Service is being performed' : 'Waiting to start work', 
                        _booking.status == 'In Progress' || _booking.status == 'Completed' ? 'Done' : '--:--', 
                        _booking.status == 'In Progress' || _booking.status == 'Completed', 
                        true
                      ),
                      _buildTimelineItem(
                        'Completion', 
                        _booking.status == 'Completed' ? 'Job finished successfully' : 'Waiting for completion', 
                        _booking.status == 'Completed' ? 'Done' : '--:--', 
                        _booking.status == 'Completed', 
                        false
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    // Material List Section
                    if (_booking.materials != null && _booking.materials!.isNotEmpty) ...[
                      const Text('MATERIALS & QUOTE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D1FF).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            if (_booking.serviceCost != null)
                              _buildPriceRow('Service Charge', _booking.serviceCost!),
                            ..._booking.materials!.map((m) {
                              final qty = m['qty'] ?? 1;
                              final price = (m['price'] as num?)?.toDouble() ?? 0.0;
                              return _buildPriceRow('${m['name'] ?? 'Item'} (x$qty)', price * qty);
                            }),
                            const Divider(color: Colors.white10, height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('₹${_booking.price}', style: const TextStyle(color: Color(0xFF00D1FF), fontSize: 20, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_booking.approvalStatus?.toLowerCase() == 'approved' || _booking.status.toLowerCase() == 'completed') ...[
                        _buildActionButton(
                          'DOWNLOAD QUOTE / INVOICE PDF', 
                          const Color(0xFF00D1FF), 
                          () => PdfService.generateInvoice(
                            booking: _booking.toMap(),
                            customerName: SupabaseService.currentUser?.userMetadata?['full_name'] ?? 'Customer',
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Inspection Photos
                      if (_booking.beforeImages != null && _booking.beforeImages!.isNotEmpty) ...[
                        const Text('INSPECTION PHOTOS', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _booking.beforeImages!.length,
                            itemBuilder: (context, i) => Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(image: NetworkImage(_booking.beforeImages![i]), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      const SizedBox(height: 30),
                    ],

                    if (_booking.status == 'Completed' && _booking.paymentStatus != 'paid')
                      Column(
                        children: [
                          const Text('Service completed! Please proceed to payment.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => _startPayment(),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF00D1FF), Color(0xFF0066FF)]),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: const Color(0xFF00D1FF).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                              ),
                              child: const Center(
                                child: Text('PAY NOW VIA RAZORPAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (_booking.paymentStatus == 'Paid')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.circleCheckBig, color: Colors.greenAccent, size: 20),
                            SizedBox(width: 10),
                            Text('PAYMENT SUCCESSFUL', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                    const SizedBox(height: 40),
                    // Technician Info
                    const Text('TECHNICIAN DETAILS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: (_booking.partnerName != null || _booking.partnerId != null)
                          ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white10,
                                  backgroundImage: _booking.partnerAvatar != null ? NetworkImage(_booking.partnerAvatar!) : null,
                                  child: _booking.partnerAvatar == null ? const Icon(LucideIcons.user, color: Colors.white60) : null,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_booking.partnerName ?? 'Technician Assigned', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      const Text('4.9 ★ • Verified Expert', style: TextStyle(color: Colors.white24, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TrackingScreen(
                                          serviceName: _booking.serviceName,
                                          brand: _booking.brand,
                                          technicianName: _booking.partnerName ?? 'Technician',
                                          technicianAvatar: _booking.partnerAvatar,
                                          partnerId: _booking.partnerId,
                                          bookingId: _booking.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), shape: BoxShape.circle),
                                    child: const Icon(LucideIcons.mapPin, color: Color(0xFF00D1FF), size: 18),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _makeCall(_booking.partnerId),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), shape: BoxShape.circle),
                                    child: const Icon(LucideIcons.phone, color: Colors.greenAccent, size: 18),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.withOpacity(0.1),
                                  ),
                                  child: const Center(
                                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber)),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Awaiting Assignment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text('We\'re finding the best technician for you', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    
                    const SizedBox(height: 40),
                    // Cancellation Policy
                    if (_booking.status != 'Cancelled' && _booking.status != 'Completed' && _booking.paymentStatus != 'Paid')
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF111827),
                                title: const Text('Cancel Booking?', style: TextStyle(color: Colors.white)),
                                content: const Text('Are you sure you want to cancel this service request?', style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('NO')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true), 
                                    child: const Text('YES, CANCEL', style: TextStyle(color: Colors.redAccent))
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              await SupabaseService.cancelBooking(_booking.id!);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Cancelled')));
                              }
                            }
                          },
                          child: Text('CANCEL BOOKING', style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      )
                    else if (_booking.status == 'Cancelled')
                      const Center(
                        child: Text('This booking was cancelled', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlow(Color color, double opacity) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(opacity)),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container()),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isCancelled = status == 'Cancelled';
    final color = isCancelled ? Colors.redAccent : const Color(0xFF00D1FF);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildTimelineItem(String title, String sub, String time, bool isDone, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF00D1FF) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? const Color(0xFF00D1FF) : Colors.white12, width: 2),
              ),
              child: isDone ? const Icon(Icons.check, color: Colors.black, size: 12) : null,
            ),
            if (showLine)
              Container(width: 2, height: 50, color: isDone ? const Color(0xFF00D1FF).withOpacity(0.3) : Colors.white12),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isDone ? Colors.white : Colors.white24, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
              const SizedBox(height: 25),
            ],
          ),
        ),
        Text(time, style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 12)),
      ],
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Text('₹$price', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
        ),
      ),
    );
  }
}
