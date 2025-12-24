import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardOverviewTab extends StatelessWidget {
  const DashboardOverviewTab({super.key});

  Future<Map<String, int>> _getStats() async {
    final products = await FirebaseFirestore.instance.collection('products').get();
    final orders = await FirebaseFirestore.instance.collection('orders').get();

    return {
      'products': products.docs.length,
      'orders': orders.docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _getStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Gagal memuat data"));
        }

        final stats = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _statCard(Icons.inventory, 'Produk', stats['products']!, Colors.blue),
              const SizedBox(width: 16),
              _statCard(Icons.shopping_cart, 'Pesanan', stats['orders']!, Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(IconData icon, String title, int value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 10),
              Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
