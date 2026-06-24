import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/services/supabase_service.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'How do I book a service?', 'a': 'Go to Home → Select a service → Choose brand & problems → Pick a date → Book Now. Our technician will reach you within 30 minutes.'},
      {'q': 'Can I cancel my booking?', 'a': 'Yes, you can cancel your booking from the Tracking screen before the technician arrives. No cancellation charges apply.'},
      {'q': 'How does live tracking work?', 'a': 'Once your technician is assigned, you can track their real-time location on the map, just like Uber.'},
      {'q': 'What payment methods do you accept?', 'a': 'We accept Cash, UPI, Wallet balance, and all major debit/credit cards.'},
      {'q': 'Is there a warranty on repairs?', 'a': 'Yes! All repairs come with a 30-day service warranty. If the same issue occurs, we fix it free of charge.'},
      {'q': 'How do I buy and get installation?', 'a': 'Switch to Buy tab → Select a product → Buy Now. Free installation is included with all products.'},
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
        title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF00D1FF).withOpacity(0.1), Colors.white.withOpacity(0.02)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    const Text('Need Help?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("We're here 24/7 for you", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactBtn(
                            LucideIcons.phone, 
                            'Call Us', 
                            Colors.greenAccent,
                            () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dialing +91 8084886252...'), backgroundColor: Colors.greenAccent)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContactBtn(
                            LucideIcons.messageCircle, 
                            'Chat', 
                            const Color(0xFF00D1FF),
                            () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening live chat...'), backgroundColor: Color(0xFF00D1FF))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContactBtn(
                            LucideIcons.mail, 
                            'Email', 
                            Colors.orangeAccent,
                            () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening email composer...'), backgroundColor: Colors.orangeAccent)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Quick Actions
              const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildActionTile(context, LucideIcons.messageSquare, 'Report a Problem', 'Issue with a recent service', () => _showReportDialog(context)),
              _buildActionTile(context, LucideIcons.refreshCw, 'Request Refund', 'Get refund for cancelled service', () {}),
              _buildActionTile(context, LucideIcons.shieldCheck, 'Warranty Claim', 'Claim your 30-day warranty', () {}),
              _buildActionTile(context, LucideIcons.fileText, 'Terms & Conditions', 'Read our policies', () {}),

              const SizedBox(height: 30),

              // FAQs
              const Text('Frequently Asked Questions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...faqs.map((faq) => _buildFAQ(faq['q']!, faq['a']!)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String sub, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white12, size: 20),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report a Problem', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Problem Title',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                    await SupabaseService.createTicket(
                      title: titleController.text,
                      description: descController.text,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ticket submitted successfully!'), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D1FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: const Color(0xFF00D1FF),
        collapsedIconColor: Colors.white24,
        title: Text(question, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        children: [
          Text(answer, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
