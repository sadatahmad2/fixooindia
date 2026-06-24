import 'package:flutter/material.dart';

class Booking {
  final String? id;
  final String serviceName;
  final String brand;
  final List<String> problems;
  final String date;
  final String status;
  final DateTime bookingTime;
  final String? partnerId;
  final String? partnerName;
  final String? partnerAvatar;
  final List<Map<String, dynamic>>? materials;
  final double? serviceCost;
  final double? price;
  final String? paymentStatus;
  final String? approvalStatus;
  final List<String>? beforeImages;
  final List<String>? afterImages;
  final double? advanceAmount;
  final String? advanceStatus;

  Booking({
    this.id,
    required this.serviceName,
    required this.brand,
    required this.problems,
    required this.date,
    this.status = 'Pending',
    required this.bookingTime,
    this.partnerId,
    this.partnerName,
    this.partnerAvatar,
    this.materials,
    this.serviceCost,
    this.price,
    this.paymentStatus,
    this.approvalStatus,
    this.beforeImages,
    this.afterImages,
    this.advanceAmount,
    this.advanceStatus,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id']?.toString(),
      serviceName: map['service_name'] ?? 'Unknown Service',
      brand: map['brand'] ?? 'Unknown',
      problems: List<String>.from(map['problems'] ?? []),
      date: map['scheduled_date'] ?? '',
      status: map['status'] ?? 'Pending',
      bookingTime: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      partnerId: map['partner_id'],
      partnerName: map['partner_name'],
      partnerAvatar: map['partner_avatar'],
      materials: map['materials'] != null ? List<Map<String, dynamic>>.from(map['materials']) : null,
      serviceCost: (map['service_cost'] as num?)?.toDouble(),
      price: (map['price'] as num?)?.toDouble(),
      paymentStatus: map['payment_status'],
      approvalStatus: map['approval_status'],
      beforeImages: map['before_images'] != null ? List<String>.from(map['before_images']) : null,
      afterImages: map['after_images'] != null ? List<String>.from(map['after_images']) : null,
      advanceAmount: (map['advance_amount'] as num?)?.toDouble(),
      advanceStatus: map['advance_status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service_name': serviceName,
      'brand': brand,
      'problems': problems,
      'scheduled_date': date,
      'status': status,
      'partner_id': partnerId,
      'partner_name': partnerName,
      'partner_avatar': partnerAvatar,
      'materials': materials,
      'service_cost': serviceCost,
      'price': price,
      'payment_status': paymentStatus,
      'approval_status': approvalStatus,
      'before_images': beforeImages,
      'after_images': afterImages,
      'advance_amount': advanceAmount,
      'advance_status': advanceStatus,
    };
  }
}

class BookingProvider with ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => _bookings;

  void addBooking(Booking booking) {
    _bookings.insert(0, booking); // Add newest at the top
    notifyListeners();
  }
}
