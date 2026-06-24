import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'package:fixoo/services/payment_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:ui';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balance = 0.0;
  bool isLoading = true;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
    // Initialize Razorpay listeners
    PaymentService.initialize(
      context,
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    PaymentService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Payment successful! Now update the wallet in Supabase
    // Note: In a real app, you'd verify the signature on the backend
    await SupabaseService.addMoney(500.0); // Hardcoded 500 for testing
    await _loadWalletData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful! Wallet Updated.'), backgroundColor: Colors.greenAccent),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet: ${response.walletName}'), backgroundColor: Colors.blueAccent),
      );
    }
  }

  Future<void> _loadWalletData() async {
    try {
      final data = await SupabaseService.getWallet();
      setState(() {
        balance = (data?['balance'] as num?)?.toDouble() ?? 0.0;
        transactions = (data?['transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
          
          SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.2)),
                    boxShadow: [BoxShadow(color: const Color(0xFF00D1FF).withOpacity(0.05), blurRadius: 30)],
                  ),
                  child: Column(
                    children: [
                      Text('AVAILABLE BALANCE', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 15),
                      Text('₹${balance.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => _showAddMoneySheet(),
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: const Text('ADD MONEY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D1FF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text('RECENT TRANSACTIONS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 25),
                
                isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D1FF)))
                  : transactions.isEmpty 
                    ? const Center(child: Text('No transactions yet', style: TextStyle(color: Colors.white24)))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return _buildTransactionItem(tx);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMoneySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Money to Wallet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Quickly add ₹500 to your wallet using Razorpay', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
            const SizedBox(height: 25),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                _startPayment(500.0);
              },
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.creditCard, color: Color(0xFF00D1FF), size: 20),
              ),
              title: const Text('Pay with Razorpay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('UPI, Cards, NetBanking', style: TextStyle(color: Colors.white24, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white10),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _startPayment(double amount) {
    final user = SupabaseService.currentUser;
    PaymentService.openCheckout(
      context: context,
      amount: amount,
      name: 'Wallet Top-up',
      description: 'Adding money to FixooIndia Wallet',
      email: user?.email ?? 'customer@fixoo.com',
      contact: user?.phone ?? '9999999999',
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    bool isCredit = tx['type'] == 'credit';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isCredit ? Colors.greenAccent.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isCredit ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight, color: isCredit ? Colors.greenAccent : Colors.redAccent, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(tx['date'] ?? 'Just now', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11)),
              ],
            ),
          ),
          Text(tx['amount'].toString(), style: TextStyle(color: isCredit ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
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
}
