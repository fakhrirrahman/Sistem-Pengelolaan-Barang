import 'package:flutter/material.dart';
import '../Models/food_product.dart';

class CartPage extends StatelessWidget {
  final List<FoodProduct> items;
  final Color accentColor;

  const CartPage({super.key, required this.items, this.accentColor = const Color(0xFF0D47A1)});

  @override
  Widget build(BuildContext context) {
    final Map<String, _CartEntry> grouped = {};
    for (final product in items) {
      grouped.update(
        product.id,
        (entry) => _CartEntry(product: entry.product, quantity: entry.quantity + 1),
        ifAbsent: () => _CartEntry(product: product, quantity: 1),
      );
    }
    final entries = grouped.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: entries.isEmpty
          ? const _EmptyCart()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = entries[index];
                return _CartTile(entry: e);
              },
            ),
      bottomNavigationBar: _CartSummary(entries: entries, accentColor: accentColor),
    );
  }
}

class _CartEntry {
  final FoodProduct product;
  int quantity;
  _CartEntry({required this.product, required this.quantity});
}

class _CartTile extends StatelessWidget {
  final _CartEntry entry;
  const _CartTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            entry.product.imagePath,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 56,
              height: 56,
              color: Colors.grey.shade300,
              child: Icon(Icons.image_not_supported, color: Colors.grey.shade600),
            ),
          ),
        ),
        title: Text(
          entry.product.name,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800),
        ),
        subtitle: Text('Qty: ${entry.quantity} • Rp ${entry.product.price.toStringAsFixed(0)}'),
        trailing: Text(
          'Rp ${(entry.product.price * entry.quantity).toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${entry.product.name} • Qty ${entry.quantity}'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        },
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final List<_CartEntry> entries;
  final Color accentColor;
  const _CartSummary({required this.entries, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final double total = entries.fold(0.0, (sum, e) => sum + (e.product.price * e.quantity));
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
                const Text('Total', style: TextStyle(color: Colors.grey)),
                Text(
                  'Rp ${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
            onPressed: entries.isEmpty ? null : () {},
            child: const Text('Checkout'),
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


