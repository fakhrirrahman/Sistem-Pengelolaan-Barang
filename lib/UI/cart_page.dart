import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/food_product.dart';
import '../Models/order.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> items;
  final Function(List<CartItem>) onUpdateCart;

  const CartPage({super.key, required this.items, required this.onUpdateCart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> cartItems;
  static const _darkBlue = Color(0xFF1F3A70);
  static const _accentOrange = Color(0xFFFFA500);
  static const _lightBg = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    cartItems = List.from(widget.items);
  }

  void checkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap login terlebih dahulu')),
      );
      return;
    }

    final total = cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    final orderItems = cartItems.map((item) => OrderItem(
      productId: item.product.id,
      name: item.product.name,
      price: item.product.price,
      quantity: item.quantity,
      total: item.product.price * item.quantity,
    )).toList();

    final order = AppOrder(
      id: '', // akan diisi oleh Firestore
      userId: user.uid,
      userEmail: user.email ?? '',
      items: orderItems,
      totalAmount: total,
      status: 'pending',
    );

    try {
      await FirebaseFirestore.instance.collection('orders').add(order.toMap());
      setState(() {
        cartItems.clear();
      });
      widget.onUpdateCart(cartItems);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout berhasil! Pesanan telah dibuat.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal checkout: $e')),
      );
    }
  }

  void updateQuantity(int index, int delta) {
    setState(() {
      cartItems[index].quantity += delta;
      if (cartItems[index].quantity <= 0) {
        cartItems.removeAt(index);
      }
    });
    widget.onUpdateCart(cartItems);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: _darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/beras.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keranjang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Pesanan Anda', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: cartItems.isEmpty
          ? const _EmptyCart()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _CartTile(
                  item: item,
                  onIncrease: () => updateQuantity(index, 1),
                  onDecrease: () => updateQuantity(index, -1),
                );
              },
            ),
      bottomNavigationBar: _CartSummary(items: cartItems, onCheckout: checkout),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  static const _accentOrange = Color(0xFFFFA500);
  
  const _CartTile({required this.item, required this.onIncrease, required this.onDecrease});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.product.imagePath.isNotEmpty
                  ? (item.product.imagePath.startsWith('http') || item.product.imagePath.startsWith('data:'))
                      ? Image.network(
                          item.product.imagePath,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 32,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        )
                      : Image.file(
                          File(item.product.imagePath),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 32,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        )
                  : Image.asset(
                      'assets/images/beras.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.product.category,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${item.product.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _accentOrange),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: onDecrease,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.remove, size: 16, color: Colors.grey.shade600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      InkWell(
                        onTap: onIncrease,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.add, size: 16, color: _accentOrange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final List<CartItem> items;
  final VoidCallback onCheckout;
  static const _darkBlue = Color(0xFF1F3A70);
  static const _accentOrange = Color(0xFFFFA500);
  
  const _CartSummary({required this.items, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final double total = items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(
                  'Rp ${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _accentOrange),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: items.isEmpty ? null : onCheckout,
            child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('Keranjang kosong', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}


