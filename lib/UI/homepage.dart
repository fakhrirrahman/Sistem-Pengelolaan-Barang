// lib/ui/homepage.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Controllers/auth_service.dart';
import '../Models/food_product.dart';
import 'cart_page.dart';
import 'order_history_page.dart';

Future<String?> getUserName(String uid) async {
  DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  if (doc.exists) {
    return doc['name'];
  }
  return null;
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _darkBlue = Color(0xFF0D47A1);
  static const _defaultUserName = 'Tidak Diketahui';

  final User? user = FirebaseAuth.instance.currentUser;
  late String userName = _defaultUserName;
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    if (user?.uid != null) {
      getUserName(user!.uid).then(
        (name) => mounted ? setState(() => userName = name ?? _defaultUserName) : null,
      );
    }
  }

  void logout(BuildContext context) => AuthService.logout(context);

  void addToCart(FoodProduct product) {
    setState(() {
      final index = cartItems.indexWhere((i) => i.product.id == product.id);
      if (index >= 0) {
        cartItems[index].quantity++;
      } else {
        cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Toko Bahan Makanan'),
        backgroundColor: _darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          _CartButton(cartItems: cartItems, onPressed: _openCart),
          _HistoryButton(onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
          )),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final products = snapshot.data!.docs
              .map((doc) => FoodProduct.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return Column(children: [
            _buildWelcomeSection(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Produk Terbaru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: products.length,
                        itemBuilder: (_, index) => _buildProductCard(products[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  void _openCart() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CartPage(
        items: cartItems,
        onUpdateCart: (items) => setState(() => cartItems = items),
      ),
    ),
  );

  Widget _buildWelcomeSection() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _darkBlue,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selamat Datang!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        const Text('Temukan bahan makanan segar terbaik', style: TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 10),
        Text('Selamat Datang: $userName', style: const TextStyle(fontSize: 14, color: Colors.white60)),
      ],
    ),
  );

  Widget _buildProductCard(FoodProduct product) => GestureDetector(
    onTap: () => addToCart(product),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildProductImage(product)),
          Expanded(flex: 2, child: _buildProductInfo(product)),
        ],
      ),
    ),
  );

  Widget _buildProductImage(FoodProduct product) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      color: Colors.grey.shade200,
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: _getImage(product),
    ),
  );

  Widget _getImage(FoodProduct product) {
    if (product.imagePath.isEmpty) return Image.asset('assets/images/beras.jpg', fit: BoxFit.cover, errorBuilder: _imageErrorBuilder);
    if (product.imagePath.startsWith('http') || product.imagePath.startsWith('data:')) {
      return Image.network(product.imagePath, fit: BoxFit.cover, errorBuilder: _imageErrorBuilder);
    }
    return Image.file(File(product.imagePath), fit: BoxFit.cover, errorBuilder: _imageErrorBuilder);
  }

  Widget _imageErrorBuilder(BuildContext context, Object error, StackTrace? trace) => Container(
    color: Colors.grey.shade300,
    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade600),
  );

  Widget _buildProductInfo(FoodProduct product) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(product.category, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rp ${product.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkBlue)),
            _buildStatusBadge(product),
          ],
        ),
      ],
    ),
  );

  Widget _buildStatusBadge(FoodProduct product) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: product.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      product.isAvailable ? 'Tersedia' : 'Habis',
      style: TextStyle(
        fontSize: 10,
        color: product.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _CartButton extends StatelessWidget {
  final List<CartItem> cartItems;
  final VoidCallback onPressed;

  const _CartButton({required this.cartItems, required this.onPressed});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Stack(
      children: [
        const Icon(Icons.shopping_cart),
        if (cartItems.isNotEmpty)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text('${cartItems.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
      ],
    ),
    onPressed: onPressed,
  );
}

class _HistoryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _HistoryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => IconButton(icon: const Icon(Icons.history), onPressed: onPressed);
}
