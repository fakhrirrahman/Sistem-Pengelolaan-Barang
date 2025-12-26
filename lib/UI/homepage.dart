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
  static const _darkBlue = Color(0xFF1F3A70);
  static const _accentOrange = Color(0xFFFFA500);
  static const _lightBg = Color(0xFFF5F5F5);
  static const _defaultUserName = 'Tidak Diketahui';

  final User? user = FirebaseAuth.instance.currentUser;
  late String userName = _defaultUserName;
  List<CartItem> cartItems = [];
  List<String> categories = ['Semua', 'Buah', 'Sayur', 'Biji-bijian', 'Bumbu'];
  String selectedCategory = 'Semua';
  late TextEditingController searchController;
  String activeSearchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    if (user?.uid != null) {
      getUserName(user!.uid).then(
        (name) => mounted ? setState(() => userName = name ?? _defaultUserName) : null,
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
      backgroundColor: _lightBg,
      appBar: _buildModernAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final allProducts = snapshot.data!.docs
              .map((doc) => FoodProduct.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          var products = allProducts;
          
          // Filter berdasarkan kategori
          if (selectedCategory != 'Semua') {
            products = products.where((p) => p.category == selectedCategory).toList();
          }
          
          // Filter berdasarkan search query
          if (activeSearchQuery.isNotEmpty) {
            products = products.where((p) => 
              p.name.toLowerCase().contains(activeSearchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(activeSearchQuery.toLowerCase())
            ).toList();
          }

          return SingleChildScrollView(
            child: Column(children: [
              _buildHeroSection(),
              _buildSearchBar(),
              _buildCategoryFilter(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Produk Terbaru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${products.length} item', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    products.isEmpty
                        ? Center(child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text('Tidak ada produk di kategori ini', style: TextStyle(color: Colors.grey.shade600)),
                          ))
                        : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, index) => _buildProductCard(products[index]),
                    ),
                  ],
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() => AppBar(
    backgroundColor: _darkBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    title: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/beras.jpg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toko Bahan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Segar Terbaik', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ],
    ),
    actions: [
      _CartButton(cartItems: cartItems, onPressed: _openCart),
      _HistoryButton(onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
      )),
      IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context)),
    ],
  );

  Widget _buildHeroSection() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [_darkBlue, _darkBlue.withOpacity(0.9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Halo, $userName 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Pesan kebutuhan dapur Anda', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
      ],
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: StatefulBuilder(
        builder: (context, setStateSearch) => Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setStateSearch(() {});
                },
                onSubmitted: (value) {
                  setState(() {
                    activeSearchQuery = searchController.text;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari produk atau kategori...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: _accentOrange),
                  suffixIcon: searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            searchController.clear();
                            setStateSearch(() {});
                            setState(() {
                              activeSearchQuery = '';
                            });
                          },
                          child: Icon(Icons.close, color: Colors.grey.shade400),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(Icons.search, color: _accentOrange, size: 24),
                onPressed: () {
                  setState(() {
                    activeSearchQuery = searchController.text;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildCategoryFilter() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: categories.map((category) {
        final isSelected = selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => selectedCategory = category),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _accentOrange : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _accentOrange : Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: _accentOrange.withOpacity(0.3), blurRadius: 8)]
                  : [],
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  void _openCart() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CartPage(
        items: cartItems,
        onUpdateCart: (items) => setState(() => cartItems = items),
      ),
    ),
  );



  Widget _buildProductCard(FoodProduct product) => GestureDetector(
    onTap: () => addToCart(product),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _getImage(product),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _buildStatusBadge(product),
              ),
            ],
          ),
          Expanded(child: _buildProductInfo(product)),
        ],
      ),
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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(product.category, style: TextStyle(fontSize: 9, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text('Rp ${product.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _accentOrange)),
      ],
    ),
  );

  Widget _buildStatusBadge(FoodProduct product) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: product.isAvailable ? Colors.green : Colors.red,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      product.isAvailable ? 'Tersedia' : 'Habis',
      style: const TextStyle(
        fontSize: 9,
        color: Colors.white,
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
