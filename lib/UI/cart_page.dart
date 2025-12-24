import 'package:flutter/material.dart';
import '../Models/food_product.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> items;
  final Color accentColor;
  final Function(List<CartItem>) onUpdateCart;

  const CartPage({super.key, required this.items, this.accentColor = const Color(0xFF0D47A1), required this.onUpdateCart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> cartItems;

  @override
  void initState() {
    super.initState();
    cartItems = List.from(widget.items);
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
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: widget.accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
      bottomNavigationBar: _CartSummary(items: cartItems, accentColor: widget.accentColor),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  const _CartTile({required this.item, required this.onIncrease, required this.onDecrease});

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
            item.product.imagePath,
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
          item.product.name,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800),
        ),
        subtitle: Text('Rp ${item.product.price.toStringAsFixed(0)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: onDecrease,
            ),
            Text('${item.quantity}'),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: onIncrease,
            ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.product.name} • Qty ${item.quantity}'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        },
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final List<CartItem> items;
  final Color accentColor;
  const _CartSummary({required this.items, required this.accentColor});

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
            onPressed: items.isEmpty ? null : () {},
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


