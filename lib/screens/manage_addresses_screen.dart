import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fixoo/services/supabase_service.dart';
import 'dart:ui';

class ManageAddressesScreen extends StatefulWidget {
  const ManageAddressesScreen({super.key});

  @override
  State<ManageAddressesScreen> createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final data = await SupabaseService.getAddresses();
      setState(() {
        addresses = data;
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
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('My Addresses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: const Color(0xFF00D1FF),
        foregroundColor: Colors.black,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Add Address', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ),
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: _buildGlow(const Color(0xFF00D1FF), 0.05)),
          
          SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Location Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D1FF).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF00D1FF).withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.locateFixed, color: Color(0xFF00D1FF), size: 22),
                      ),
                      const SizedBox(width: 18),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Current Location', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Enable GPS for auto-detection', style: TextStyle(color: Colors.white24, fontSize: 12)),
                      ])),
                      const Icon(Icons.chevron_right, color: Color(0xFF00D1FF), size: 20),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text('SAVED ADDRESSES', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 25),
                
                ...addresses.map((addr) => _buildAddressCard(addr)),
                if (isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFF00D1FF))),
                if (!isLoading && addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(child: Text('No addresses saved yet.', style: TextStyle(color: Colors.white24))),
                  ),
                const SizedBox(height: 100),
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

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    bool isHome = addr['type'] == 'Home';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
            child: Icon(isHome ? LucideIcons.house : LucideIcons.briefcase, color: const Color(0xFF00D1FF).withOpacity(0.8), size: 20),
          ),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(addr['type']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(addr['address']!, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13, height: 1.4)),
          ])),
          PopupMenuButton(
            icon: Icon(LucideIcons.ellipsisVertical, color: Colors.white.withOpacity(0.2), size: 18),
            color: const Color(0xFF162436),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
            ],
            onSelected: (val) async {
              if (val == 'delete') {
                if (addr['id'] != null) {
                  await SupabaseService.deleteAddress(addr['id']);
                  _loadAddresses();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    final typeController = TextEditingController();
    final addressController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(ctx).viewInsets.bottom + 25),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('New Address', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          TextField(
            controller: typeController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Label (e.g. Home, Office)',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: addressController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Detailed Address',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(width: double.infinity, height: 60, child: ElevatedButton(
            onPressed: () async {
              if (typeController.text.isNotEmpty && addressController.text.isNotEmpty) {
                await SupabaseService.addAddress(typeController.text, addressController.text);
                if (mounted) {
                  Navigator.pop(ctx);
                  _loadAddresses();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D1FF), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.w900)),
          )),
        ]),
      ),
    );
  }
}
