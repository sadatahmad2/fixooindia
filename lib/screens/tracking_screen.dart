import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fixoo/screens/submit_review_screen.dart';
import 'package:fixoo/services/pdf_service.dart';

class TrackingScreen extends StatefulWidget {
  final String serviceName;
  final String brand;
  final String? technicianName;
  final String? technicianAvatar;
  final String? partnerId;
  final String? bookingId;

  const TrackingScreen({
    super.key,
    required this.serviceName,
    required this.brand,
    this.technicianName,
    this.technicianAvatar,
    this.partnerId,
    this.bookingId,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Map<String, dynamic> _booking;
  bool _techAssigned = false;
  String _techName = '';
  String? _techAvatar;
  String? _techPhone;
  bool _isSearching = true;
  bool _isInitialLoad = true;
  bool _isLoading = false;
  late Razorpay _razorpay;
  
  LatLng? _partnerLoc;
  LatLng? _customerLoc;
  double _distance = 0.0;
  String _duration = '';
  GoogleMapController? _mapController;
  StreamSubscription? _locationSub;
  StreamSubscription? _customerUpdateSub;
  StreamSubscription? _bookingSub;
  Timer? _pollTimer;
  Set<Polyline> _polylines = {};

  final String googleApiKey = 'AIzaSyCM0Go-ytBf82bdg1WpjfYH4IZVm38c7p4';

  List<Map<String, dynamic>> _getSteps() {
    final status = (_booking['status'] ?? 'Pending').toString().toLowerCase();
    final approvalStatus = (_booking['approval_status'] ?? 'none').toString().toLowerCase();
    final advanceStatus = (_booking['advance_status'] ?? 'none').toString().toLowerCase();
    final partnerId = _booking['partner_id'];

    return [
      {'title': 'Booking Confirmed', 'sub': 'Your request has been received', 'icon': LucideIcons.circleCheckBig, 'key': 'confirmed'},
      {'title': 'Technician Assigned', 'sub': partnerId != null ? 'Technician is assigned' : 'Finding the best technician for you', 'icon': LucideIcons.user, 'key': 'assigned'},
      {'title': 'On The Way', 'sub': 'Technician is heading to your location', 'icon': LucideIcons.navigation, 'key': 'accepted'},
      {'title': 'Arrived', 'sub': 'Technician has reached your location', 'icon': LucideIcons.mapPin, 'key': 'arrived'},
      {'title': 'Inspection & Quote', 'sub': approvalStatus == 'approved' ? 'Quote Approved' : (approvalStatus == 'rejected' ? 'Quote Rejected' : (approvalStatus == 'pending' ? 'Quote sent for approval' : 'Waiting for inspection')), 'icon': LucideIcons.listTodo, 'key': 'quote'},
      {'title': 'Advance Payment', 'sub': advanceStatus == 'paid' ? 'Payment received successfully' : 'Advance payment required', 'icon': LucideIcons.indianRupee, 'key': 'advance'},
      {'title': 'Work In Progress', 'sub': 'Your issue is being fixed', 'icon': LucideIcons.wrench, 'key': 'in progress'},
      {'title': 'Completed', 'sub': 'Service completed successfully', 'icon': LucideIcons.circleCheckBig, 'key': 'completed'},
    ];
  }

  @override
  void initState() {
    super.initState();
    _booking = {
      'id': widget.bookingId,
      'status': 'Pending',
      'service_name': widget.serviceName,
      'brand': widget.brand,
      'partner_name': widget.technicianName,
      'partner_avatar': widget.technicianAvatar,
      'partner_id': widget.partnerId,
    };
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadPartnerInfo();
    _fetchCustomerLocation();
    _startUpdatingMyGeolocation();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) _loadPartnerInfo();
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Handling is done in the _startPayment callback usually, 
    // but we can add global handling here if needed.
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  Future<void> _fetchCustomerLocation() async {
    try {
      Position? lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        setState(() {
          _customerLoc = LatLng(lastPos.latitude, lastPos.longitude);
        });
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_customerLoc!, 15));
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          _customerLoc = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_customerLoc!, 15));
        _getRoute();
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  Future<void> _getRoute() async {
    if (_partnerLoc == null || _customerLoc == null) return;

    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${_partnerLoc!.latitude},${_partnerLoc!.longitude}&'
        'destination=${_customerLoc!.latitude},${_customerLoc!.longitude}&'
        'key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final leg = data['routes'][0]['legs'][0];
          
          if (mounted) {
            setState(() {
              _distance = (leg['distance']['value'] as int) / 1000;
              _duration = leg['duration']['text'];
              _polylines = {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: _decodePolyline(points),
                  color: const Color(0xFF00D1FF),
                  width: 5,
                  jointType: JointType.round,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                ),
              };
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> _loadPartnerInfo() async {
    // 1. Initial State
    if (widget.technicianName != null && widget.technicianName!.isNotEmpty) {
      _techName = widget.technicianName!;
      _techAvatar = widget.technicianAvatar;
      _isSearching = false;
    }

    // 2. Initial Fetch and Real-time listener for Booking Status
    if (widget.bookingId != null) {
      // Immediate fetch
      try {
        final booking = await SupabaseService.client
            .from('bookings')
            .select()
            .eq('id', widget.bookingId!)
            .maybeSingle();
        if (booking != null && mounted) {
          setState(() {
            _booking = booking;
            _isInitialLoad = false;
            if (booking['partner_id'] != null) {
              _techAssigned = true;
              _isSearching = false;
              _fetchPartnerProfile(booking['partner_id']);
            }
          });
        }
      } catch (e) {
        debugPrint('DEBUG: Initial fetch error: $e');
      }
      
      _listenToBookingStatus(widget.bookingId!);
    }

    // 3. If we have a partner ID, listen to their location
    if (widget.partnerId != null) {
      _fetchPartnerProfile(widget.partnerId!);
    }
  }

  void _listenToBookingStatus(String bookingId) {
    _bookingSub?.cancel();
    _bookingSub = SupabaseService.client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('id', bookingId)
        .listen((data) {
          if (data.isNotEmpty && mounted) {
            final b = data.first;
            debugPrint('DEBUG: Customer App Stream Update - Status: ${b['status']}, Approval: ${b['approval_status']}, Price: ${b['price']}');
            // Immediate state update for any change
            setState(() {
              _booking = Map<String, dynamic>.from(b);
              if (b['partner_id'] != null) {
                _techAssigned = true;
                _isSearching = false;
                if (_partnerLoc == null) {
                  _fetchPartnerProfile(b['partner_id']);
                }
              }
            });
          } else if (data.isEmpty) {
            debugPrint('DEBUG: Customer App Stream received EMPTY data for ID: $bookingId');
          }
        });
  }

  int _getCurrentStep(List<Map<String, dynamic>> steps) {
    String status = (_booking['status'] ?? 'Pending').toString().toLowerCase();
    String approvalStatus = (_booking['approval_status'] ?? 'none').toString().toLowerCase();
    String advanceStatus = (_booking['advance_status'] ?? 'none').toString().toLowerCase();
    String? partnerId = _booking['partner_id'];

    if (status == 'completed') return steps.length - 1;
    if (status == 'in progress') return steps.indexWhere((s) => s['key'] == 'in progress');
    
    // 1. Handle Approved Quote logic first to allow progression
    if (approvalStatus == 'approved') {
      if (advanceStatus == 'pending' || advanceStatus == 'none' || advanceStatus == '' || advanceStatus == 'cash_requested') {
        // If there's an advance amount > 0 or cash requested, stay on advance step
        double advAmount = double.tryParse(_booking['advance_amount']?.toString() ?? '0') ?? 0.0;
        if (advAmount > 0 || advanceStatus == 'cash_requested') {
          return steps.indexWhere((s) => s['key'] == 'advance');
        }
      }
      // If no advance or advance paid, and status is still Quoted/Arrived, show next step (In Progress)
      if (status == 'in progress' || status == 'quoted' || status == 'arrived') {
        return steps.indexWhere((s) => s['key'] == 'in progress');
      }
    }

    // 2. If quote is pending or rejected, we focus on quote step
    if (approvalStatus == 'pending' || approvalStatus == 'rejected' || status == 'quoted') {
      return steps.indexWhere((s) => s['key'] == 'quote');
    }

    if (status == 'arrived') return steps.indexWhere((s) => s['key'] == 'arrived');
    if (status == 'accepted') return steps.indexWhere((s) => s['key'] == 'accepted');
    if (partnerId != null || status == 'assigned') return steps.indexWhere((s) => s['key'] == 'assigned');
    return 0;
  }

  Future<void> _fetchPartnerProfile(String partnerId) async {
    try {
      final profile = await SupabaseService.client
          .from('profiles')
          .select('name, full_name, avatar_url, phone, latitude, longitude')
          .eq('id', partnerId)
          .maybeSingle();
      if (profile != null && mounted) {
        setState(() {
          _techName = profile['name'] ?? profile['full_name'] ?? 'Technician';
          _techAvatar = profile['avatar_url'];
          _techPhone = profile['phone'];
          _isSearching = false;
          if (profile['latitude'] != null && profile['longitude'] != null) {
            _partnerLoc = LatLng(profile['latitude'], profile['longitude']);
          }
        });
        _listenToPartnerLocation(partnerId);
        _getRoute();
      }
    } catch (e) {
      debugPrint('Error fetching partner profile: $e');
    }
  }

  void _listenToPartnerLocation(String partnerId) {
    _locationSub?.cancel();
    _locationSub = SupabaseService.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', partnerId)
        .listen((data) {
          if (data.isNotEmpty && mounted) {
            final p = data.first;
            setState(() {
              if (p['latitude'] != null && p['longitude'] != null) {
                _partnerLoc = LatLng(p['latitude'], p['longitude']);
                if (!_isSearching) {
                   _mapController?.animateCamera(CameraUpdate.newLatLng(_partnerLoc!));
                }
              }
            });
            _getRoute();
          }
        });
  }

  void _startUpdatingMyGeolocation() {
    _customerUpdateSub?.cancel();
    _customerUpdateSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((position) async {
      if (widget.bookingId != null) {
        await SupabaseService.client.from('bookings').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }).eq('id', widget.bookingId!);
      }
      if (mounted) {
        setState(() {
          _customerLoc = LatLng(position.latitude, position.longitude);
        });
        _getRoute();
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    _pollTimer?.cancel();
    _pulseController.dispose();
    _locationSub?.cancel();
    _customerUpdateSub?.cancel();
    _bookingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040C18),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(widget.serviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 18),
            onPressed: () => _loadPartnerInfo(),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(LucideIcons.phone, color: Color(0xFF00D1FF), size: 18),
              onPressed: () => _makeCall(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _partnerLoc ?? _customerLoc ?? const LatLng(26.8467, 80.9462),
              zoom: 14,
            ),
            polylines: _polylines,
            markers: {
              if (_partnerLoc != null)
                Marker(
                  markerId: const MarkerId('technician'),
                  position: _partnerLoc!,
                  infoWindow: const InfoWindow(title: 'Technician'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
                ),
              if (_customerLoc != null)
                Marker(
                  markerId: const MarkerId('customer'),
                  position: _customerLoc!,
                  infoWindow: const InfoWindow(title: 'My Location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
          ),
          if (_distance > 0)
            Positioned(
              top: 110,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2E),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.navigation, color: Color(0xFF00D1FF), size: 14),
                    const SizedBox(width: 8),
                    Text(
                      '${_distance.toStringAsFixed(1)} km away${_duration.isNotEmpty ? " • $_duration" : ""}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                  ],
                ),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: ((_booking['approval_status'] ?? '').toString().toLowerCase() == 'pending') ? 0.6 : 0.35,
            minChildSize: 0.20,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2E),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)],
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 20),
                      
                      // Action Required Banner
                      if ((_booking['approval_status'] ?? '').toString().toLowerCase() == 'pending')
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                              SizedBox(width: 8),
                              Text('ACTION REQUIRED: APPROVE QUOTE', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                            ],
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _isSearching ? _buildSearchingUI() : _buildTechnicianUI(),
                      ),
                      
                      // Action buttons are now integrated into the timeline list below

                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'ID: ${_booking['id']} | Status: ${_booking['status']} | Approval: ${_booking['approval_status']}',
                          style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 24),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _getSteps().length,
                        itemBuilder: (context, index) {
                          final steps = _getSteps();
                          final currentStep = _getCurrentStep(steps);
                          bool isCompleted = index < currentStep;
                          bool isCurrent = index == currentStep;
                          return _buildStepItem(index, isCompleted, isCurrent, steps);
                        },
                      ),

                      if ((_booking['approval_status'] ?? '').toString().toLowerCase() == 'approved') ...[
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildActionButton(
                            'DOWNLOAD QUOTE / INVOICE PDF', 
                            const Color(0xFF00D1FF), 
                            () => PdfService.generateInvoice(
                              booking: _booking, 
                              customerName: SupabaseService.currentUser?.email?.split('@')[0].toUpperCase() ?? 'CUSTOMER'
                            ),
                            icon: LucideIcons.fileDown
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  void _updateApproval(String status) async {
    try {
      final dynamic bookingId = _booking['id'];
      final partnerId = _booking['partner_id'];

      debugPrint('DEBUG: Attempting to update approval for ID: $bookingId to status: $status');

      // 1. Update Supabase - We don't use .select() here to avoid RLS 'select' permission issues
      await SupabaseService.client.from('bookings').update({
        'approval_status': status,
      }).eq('id', bookingId);

      debugPrint('DEBUG: Approval update request sent.');

      // 2. Notify Partner
      if (partnerId != null) {
        try {
          await SupabaseService.client.from('notifications').insert({
            'user_id': partnerId,
            'title': status == 'approved' ? 'Quote Approved!' : 'Quote Rejected',
            'body': status == 'approved' 
                ? 'Customer has approved your quote. You can now proceed with the work.' 
                : 'Customer has rejected the quote. Please discuss with the customer.',
            'icon_name': status == 'approved' ? 'check-circle' : 'x-circle',
          });
        } catch (notifErr) {
          debugPrint('DEBUG: Notification error (non-critical): $notifErr');
        }
      }

      // 3. Update Local State for immediate feedback
      if (mounted) {
        setState(() {
          _booking['approval_status'] = status;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quote ${status.toUpperCase()} processed!'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('DEBUG: Critical Approval Error: $e');
      if (mounted) {
        showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Update Failed'),
          content: Text('Could not update approval status. This is likely a database permission (RLS) issue.\n\nError: $e'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ));
      }
    }
  }

  void _startPayment({double? customAmount, bool isAdvance = false}) {
    final amount = customAmount ?? (_booking['price'] as num?)?.toDouble();
    if (amount == null || amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid payment amount'), backgroundColor: Colors.orange));
      return;
    }

    var options = {
      'key': 'rzp_test_SifkAZASCn3YXX', 
      'amount': (amount * 100).toInt(),
      'name': 'FixooIndia Services',
      'description': isAdvance ? 'Advance for ${_booking['service_name']}' : 'Payment for ${_booking['service_name']}',
      'prefill': {
        'contact': SupabaseService.currentUser?.phone ?? '',
        'email': SupabaseService.currentUser?.email ?? '',
      },
      'notes': {
        'booking_id': _booking['id'],
        'type': isAdvance ? 'advance' : 'full'
      }
    };

    _razorpay.clear();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
      try {
        if (isAdvance) {
          await SupabaseService.client.from('bookings').update({
            'advance_status': 'paid',
            'advance_amount': amount,
          }).eq('id', _booking['id']);
        } else {
          await SupabaseService.updatePaymentStatus(_booking['id'].toString(), 'paid', response.paymentId ?? '');
        }

        // FORCE REFRESH LOCAL STATE
        await _loadPartnerInfo(); 
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green));
        }
      } catch (e) {
        debugPrint('DEBUG: Payment update error: $e');
      }
    });

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap, {IconData? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
            ],
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingUI() {
    return Row(
      children: [
        Container(
          width: 55, height: 55,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.amber.withOpacity(0.1)),
          child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Finding Technician...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Requesting nearby specialists', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicianUI() {
    return Row(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(_techAvatar ?? 'https://i.pravatar.cc/150?u=$_techName'),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: const Color(0xFF00D1FF), width: 2),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_techName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 14),
                  SizedBox(width: 4),
                  Text('4.8 • Top Rated', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(LucideIcons.phone, color: Color(0xFF00D1FF), size: 20),
            onPressed: () => _makeCall(),
          ),
        ),
      ],
    );
  }

  void _makeCall() async {
    if (_techPhone == null || _techPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: _techPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  Widget _buildStepItem(int index, bool isCompleted, bool isCurrent, List<Map<String, dynamic>> steps) {
    final stepKey = steps[index]['key'];
    final approvalStatus = (_booking['approval_status'] ?? '').toString().toLowerCase();
    final advanceStatus = (_booking['advance_status'] ?? '').toString().toLowerCase();
    final status = (_booking['status'] ?? '').toString().toLowerCase();

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? const Color(0xFF0FF4C6) : (isCurrent ? const Color(0xFF00D1FF).withOpacity(0.2) : Colors.white10),
                    border: isCurrent ? Border.all(color: const Color(0xFF00D1FF), width: 2) : null,
                  ),
                  child: Center(
                    child: isCurrent 
                      ? ScaleTransition(
                          scale: _pulseAnimation,
                          child: Icon(steps[index]['icon'] ?? Icons.access_time, size: 14, color: const Color(0xFF00D1FF)),
                        )
                      : Icon(
                          isCompleted ? Icons.check : (steps[index]['icon'] ?? Icons.circle),
                          size: 14, color: isCompleted ? Colors.black : Colors.white10,
                        ),
                  ),
                ),
                if (index != steps.length - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? const Color(0xFF0FF4C6) : Colors.white10,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(steps[index]['title'], style: TextStyle(color: isCurrent ? Colors.white : (isCompleted ? Colors.white70 : Colors.white24), fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(steps[index]['sub'], style: TextStyle(color: isCurrent ? Colors.white54 : Colors.white10, fontSize: 12)),
                    
                    if (isCurrent && stepKey == 'quote' && approvalStatus == 'pending') ...[
                      const SizedBox(height: 16),
                      _buildInternalQuoteApproval(),
                    ],
                    if (isCurrent && stepKey == 'advance' && advanceStatus != 'paid') ...[
                      const SizedBox(height: 16),
                      _buildInternalAdvancePayment(),
                    ],
                    if (isCurrent && stepKey == 'completed') ...[
                      const SizedBox(height: 16),
                      if ((_booking['payment_status'] ?? '').toString().toLowerCase() != 'paid')
                        _buildInternalFinalPayment()
                      else
                        _buildActionButton('GIVE FEEDBACK', const Color(0xFF00D1FF), () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitReviewScreen(booking: _booking)));
                        }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternalQuoteApproval() {
    final rawMaterials = _booking['materials'];
    List<Map<String, dynamic>> materials = [];
    if (rawMaterials is List) {
      materials = List<Map<String, dynamic>>.from(rawMaterials.map((x) => Map<String, dynamic>.from(x as Map)));
    }
    final double total = double.tryParse(_booking['price']?.toString() ?? '0') ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00D1FF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...materials.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${m['name'] ?? 'Item'} (x${m['qty'] ?? 1})', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('₹${((m['price'] ?? 0) as num) * ((m['qty'] ?? 1) as num)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
          const Divider(color: Colors.white10, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('₹$total', style: const TextStyle(color: Color(0xFF0FF4C6), fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildActionButton('REJECT', Colors.redAccent, () => _updateApproval('rejected'))),
              const SizedBox(width: 10),
              Expanded(child: _buildActionButton('APPROVE', const Color(0xFF0FF4C6), () => _updateApproval('approved'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInternalAdvancePayment() {
    final double amount = double.tryParse(_booking['advance_amount']?.toString() ?? '0') ?? 0.0;
    final String advanceStatus = (_booking['advance_status'] ?? '').toString().toLowerCase();
    final String? otp = _booking['payment_otp']?.toString();

    if (advanceStatus == 'cash_requested') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.2))),
        child: Column(
          children: [
            const Text('CASH PAYMENT REQUESTED', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('Please give cash to the technician and share this OTP:', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
              child: Text(otp ?? '----', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber.withOpacity(0.2))),
      child: Column(
        children: [
          Text('Please pay ₹$amount advance to start work.', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          _buildActionButton('PAY ₹$amount ONLINE', Colors.amber, () => _startPayment(customAmount: amount, isAdvance: true)),
          const SizedBox(height: 8),
          _buildActionButton('PAY BY CASH', Colors.white70, () => _requestCashPayment(amount, true)),
        ],
      ),
    );
  }

  void _requestCashPayment(double amount, bool isAdvance) async {
    // Generate a secure 4-digit OTP
    final random = (1000 + (DateTime.now().millisecond % 9000)).toString();
    try {
      setState(() {
        _isLoading = true;
        // Update local state immediately for instant feedback
        _booking[isAdvance ? 'advance_status' : 'payment_status'] = 'cash_requested';
        _booking['payment_otp'] = random;
      });
      
      await SupabaseService.client.from('bookings').update({
        isAdvance ? 'advance_status' : 'payment_status': 'cash_requested',
        'payment_otp': random,
      }).eq('id', _booking['id']);
      
      // Notify partner that cash is ready for verification
      final partnerId = _booking['partner_id'];
      if (partnerId != null) {
        await SupabaseService.client.from('notifications').insert({
          'user_id': partnerId,
          'title': 'Cash Payment Ready',
          'body': 'The customer wants to pay by cash. Please verify the OTP.',
          'icon_name': 'indian-rupee',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash payment requested! Share OTP with technician.'), backgroundColor: Color(0xFF00D1FF)),
      );
    } catch (e) {
      debugPrint('Error requesting cash: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to request cash payment.'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInternalFinalPayment() {
    final double total = double.tryParse(_booking['price']?.toString() ?? '0') ?? 0.0;
    final double advance = double.tryParse(_booking['advance_amount']?.toString() ?? '0') ?? 0.0;
    final double remainingAmount = total - advance;

    final String paymentStatus = (_booking['payment_status'] ?? '').toString().toLowerCase();
    final String? otp = _booking['payment_otp']?.toString();

    if (paymentStatus == 'cash_requested') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.2))),
        child: Column(
          children: [
            const Text('FINAL CASH PAYMENT REQUESTED', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Text('Share this OTP after giving ₹$remainingAmount cash:', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
              child: Text(otp ?? '----', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.2))),
      child: Column(
        children: [
          Text('Final Amount: ₹$remainingAmount', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _buildActionButton('PAY ONLINE', const Color(0xFF00D1FF), () => _startPayment(customAmount: remainingAmount)),
          const SizedBox(height: 8),
          _buildActionButton('PAY BY CASH', Colors.white70, () => _requestCashPayment(remainingAmount, false)),
        ],
      ),
    );
  }
}
