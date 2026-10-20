// lib/screens/cart_checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../core/services/storefront_api_service.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  String _paymentMethod = 'cod';
  bool _submitting = false;

  Future<void> _submitOrder() async {
    final store = context.read<StoreProvider>();
    if (store.cart.isEmpty) return;
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে নাম, মোবাইল নম্বর ও ঠিকানা পূরণ করুন।')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await StorefrontApiService.placeOrder(
        customerName: _nameCtrl.text,
        customerPhone: _phoneCtrl.text,
        shippingAddress: _addressCtrl.text,
        paymentMethod: _paymentMethod,
        items: store.cart,
      );
      store.clearCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('অর্ডার সফলভাবে সম্পন্ন হয়েছে!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: store.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Shopping Cart & Checkout', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
      body: store.cart.isEmpty
          ? const Center(child: Text('আপনার কার্ট বর্তমানে খালি।'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...store.cart.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('৳${item.product.price.toStringAsFixed(0)} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => store.updateQuantity(item.product.id, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900)),
                            IconButton(
                              onPressed: () => store.updateQuantity(item.product.id, 1),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('ডেলিভারি তথ্য (Cash On Delivery / Online)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'আপনার নাম (Full Name)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'মোবাইল নম্বর (Phone Number)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'ডেলিভারি ঠিকানা (Full Address)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('সর্বমোট (Total Payable):', style: TextStyle(fontWeight: FontWeight.w800)),
                          Text(
                            '৳${store.cartTotal.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: store.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: store.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _submitting ? 'অর্ডার প্রসেস হচ্ছে...' : 'Confirm Order (COD)',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
