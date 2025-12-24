import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryTab extends StatelessWidget {
  const OrderHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('orders').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final doc = orders[index];
            final data = doc.data() as Map<String, dynamic>;

            final date = (data['createdAt'] as Timestamp).toDate();

            final items = data['items'] as List<dynamic>;
            final firstItem = items.isNotEmpty ? items[0]['name'] : 'No items';
            final itemCount = items.length;

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('Order ${doc.id.substring(0, 8)}'),
                subtitle: Text(
                  'User: ${data['userEmail']}\nBarang: $firstItem${itemCount > 1 ? ' +${itemCount - 1} lainnya' : ''}\nTotal: Rp${data['totalAmount']}\nTanggal: ${date.toLocal().toString().split(' ')[0]}',
                ),
                onTap: () => _showDetail(context, data),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    final items = data['items'] as List<dynamic>;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((e) => Text('- ${e['name']} x${e['quantity']}'))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
