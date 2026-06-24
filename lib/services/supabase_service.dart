import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixoo/config/supabase_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static String? _mockMembership; // Reset to null for testing flow

  // ============ AUTH ============

  static Future<void> sendOTP(String phone) async {
    final fullPhone = phone.startsWith('+') ? phone : '+91$phone';
    await client.auth.signInWithOtp(phone: fullPhone);
  }

  static Future<dynamic> verifyOTP(String phone, String otp) async {
    final fullPhone = phone.startsWith('+') ? phone : '+91$phone';
    try {
      final response = await client.auth.verifyOTP(phone: fullPhone, token: otp, type: OtpType.sms);
      if (response.user != null) {
        await _ensureProfileAndWallet(response.user!);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      const webClientId = '745187823839-t30vs2iekdeqvbamegh9ra5gigs3jiep.apps.googleusercontent.com';
      const iosClientId = '745187823839-at8pcnj43sqq07655lh3d6jp8kgiu10e.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'No ID Token found.';

      final response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        await _ensureProfileAndWallet(response.user!);
      }

      return response;
    } catch (e) {
      print('DEBUG: Google Sign In Error: $e');
      rethrow;
    }
  }

  static Future<void> _ensureProfileAndWallet(User user) async {
    try {
      final profile = await client.from('profiles').select().eq('id', user.id).maybeSingle();
      final metadata = user.userMetadata ?? {};
      
      final String displayName = metadata['full_name'] ?? 
                                 metadata['name'] ?? 
                                 user.email?.split('@')[0] ?? 
                                 'New User';
                                 
      final googleEmail = user.email ?? metadata['email'];
      final googleAvatar = metadata['avatar_url'] ?? metadata['picture'];

      if (profile == null) {
        await client.from('profiles').insert({
          'id': user.id,
          'phone': user.phone,
          'email': googleEmail,
          'full_name': displayName,
          'name': displayName,
          'avatar_url': googleAvatar,
        });
      } else {
        // Update if existing info is missing
        final updates = <String, dynamic>{};
        if (profile['full_name'] == null || profile['full_name'] == 'New User') {
          updates['full_name'] = displayName;
          updates['name'] = displayName;
        }
        if (profile['email'] == null) updates['email'] = googleEmail;
        if (profile['avatar_url'] == null) updates['avatar_url'] = googleAvatar;
        
        if (updates.isNotEmpty) {
          await client.from('profiles').update(updates).eq('id', user.id);
        }
      }

      final wallet = await client.from('wallet').select().eq('user_id', user.id).maybeSingle();
      if (wallet == null) {
        await client.from('wallet').insert({
          'user_id': user.id,
          'balance': 0.0,
        });
      }
    } catch (e) {
      print('DEBUG: Error in _ensureProfileAndWallet: $e');
    }
  }

  static User? get currentUser {
    return client.auth.currentUser;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ============ PROFILE ============

  static Future<Map<String, dynamic>?> getProfile() async {
    if (SupabaseConfig.useMock) {
      return {
        'id': 'mock-id',
        'full_name': 'sadat Ahmad',
        'name': 'sadat Ahmad',
        'membership_type': _mockMembership,
        'is_plus_member': _mockMembership != null,
      };
    }
    if (currentUser == null) return null;
    return await client.from('profiles').select().eq('id', currentUser!.id).maybeSingle();
  }

  static Future<void> updateProfile({required String name, required String email, required String phone, String? avatarUrl}) async {
    if (currentUser == null) return;
    await client.from('profiles').upsert({
      'id': currentUser!.id,
      'name': name,
      'email': email,
      'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateMembership(String planName) async {
    try {
      if (SupabaseConfig.useMock) {
        _mockMembership = planName;
        debugPrint('MOCK: Membership updated to $planName');
        return;
      }
      
      final user = currentUser;
      if (user == null) {
        debugPrint('DB Error: No current user found');
        return;
      }

      int expiryDays = 30;
      if (planName == 'Pro') expiryDays = 180; // 6 months
      if (planName == 'Ultra') expiryDays = 365; // 12 months

      final response = await client.from('profiles').update({
        'is_plus_member': true,
        'membership_type': planName,
        'membership_expiry': DateTime.now().add(Duration(days: expiryDays)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id).select();

      // Log Transaction
      await client.from('transactions').insert({
        'user_id': user.id,
        'title': 'Bought $planName Plus Membership',
        'amount': '-₹${planName == 'Basic' ? 199 : planName == 'Pro' ? 999 : 1799}',
        'type': 'debit',
        'date': 'Today',
        'created_at': DateTime.now().toIso8601String()
      });

      debugPrint('DB Update Success: $response');
    } catch (e) {
      debugPrint('DB Update Failed: $e');
      rethrow;
    }
  }

  // ============ BOOKINGS ============

  static Future<String?> createBooking({
    required String serviceName,
    required String brand,
    required List<String> problems,
    required String scheduledDate,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    if (currentUser == null) return null;
    
    // Get user name from metadata
    final metadata = currentUser!.userMetadata ?? {};
    final userName = metadata['full_name'] ?? metadata['name'] ?? 'Customer';
    final userPhone = currentUser!.phone ?? '';

    final result = await client.from('bookings').insert({
      'user_id': currentUser!.id,
      'customer_name': userName,
      'customer_phone': userPhone,
      'service_name': serviceName,
      'brand': brand,
      'problems': problems,
      'scheduled_date': scheduledDate,
      'address': address ?? 'Current Location',
      'latitude': latitude,
      'longitude': longitude,
      'status': 'Pending',
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').single();
    return result['id'] as String?;
  }

  static Future<List<Map<String, dynamic>>> getBookings() async {
    if (currentUser == null) return [];
    final data = await client.from('bookings').select().eq('user_id', currentUser!.id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // ============ PARTNERS ============

  static Future<List<Map<String, dynamic>>> getOnlinePartners() async {
    try {
      final response = await client
          .from('profiles')
          .select('id, name, full_name, avatar_url, skills')
          .eq('is_online', true)
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting online partners: $e');
      return [];
    }
  }

  static Stream<List<Map<String, dynamic>>> getOnlinePartnersStream() {
    return client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('is_online', true)
        .limit(10);
  }

  static Future<int> getOnlinePartnersCount() async {
    try {
      final response = await client
          .from('profiles')
          .select('id')
          .eq('is_online', true);
      return (response as List).length;
    } catch (e) {
      print('Error getting online partners count: $e');
      return 0;
    }
  }

  // ============ WALLET & TRANSACTIONS ============

  static Future<double> getWalletBalance() async {
    if (currentUser == null) return 0.0;
    final data = await client.from('wallet').select('balance').eq('user_id', currentUser!.id).maybeSingle();
    return (data?['balance'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    if (currentUser == null) return [];
    final data = await client.from('transactions').select().eq('user_id', currentUser!.id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addMoney(double amount) async {
    if (currentUser == null) return;
    final currentBalance = await getWalletBalance();
    
    // Update Wallet
    await client.from('wallet').upsert({'user_id': currentUser!.id, 'balance': currentBalance + amount});
    
    // Insert Transaction
    await client.from('transactions').insert({
      'user_id': currentUser!.id,
      'title': 'Added to Wallet',
      'amount': '+₹${amount.toInt()}',
      'type': 'credit',
      'date': 'Today', // Better to use a real formatted date here, or let UI format 'created_at'
      'created_at': DateTime.now().toIso8601String()
    });
  }

  static Future<Map<String, dynamic>?> getWallet() async {
    final balance = await getWalletBalance();
    final transactions = await getTransactions();
    return {
      'balance': balance,
      'transactions': transactions,
    };
  }

  // ============ ADDRESSES ============

  static Future<List<Map<String, dynamic>>> getAddresses() async {
    if (currentUser == null) return [];
    final data = await client.from('addresses').select().eq('user_id', currentUser!.id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addAddress(String type, String address) async {
    if (currentUser == null) return;
    await client.from('addresses').insert({
      'user_id': currentUser!.id,
      'type': type,
      'address': address,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteAddress(int addressId) async {
    if (currentUser == null) return;
    await client.from('addresses').delete().eq('id', addressId);
  }

  // ============ CANCELLATION ============

  static Future<void> cancelBooking(String bookingId) async {
    if (currentUser == null) return;
    await client.from('bookings').update({
      'status': 'Cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  static Future<void> updatePaymentStatus(String bookingId, String status, String paymentId) async {
    await client.from('bookings').update({
      'payment_status': status,
      'payment_id': paymentId,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  // ============ TICKETS / SUPPORT ============

  static Future<void> createTicket({
    required String title,
    required String description,
    String? category,
  }) async {
    if (currentUser == null) return;
    await client.from('tickets').insert({
      'user_id': currentUser!.id,
      'title': title,
      'description': description,
      'category': category ?? 'General',
      'status': 'Open',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
