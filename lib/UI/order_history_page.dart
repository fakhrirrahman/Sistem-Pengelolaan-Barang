// lib/UI/order_history_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/order.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Pesanan')),
        body: const Center(child: Text('Harap login terlebih dahulu')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error loading orders: ${snapshot.error}'); // Debug log
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final orders = snapshot.data!.docs.map((doc) {
              return AppOrder.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();

          orders.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
            }

            return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${order.id.substring(0, 8)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: order.status == 'pending' ? Colors.orange.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  color: order.status == 'pending' ? Colors.orange.shade700 : Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Total: Rp ${order.totalAmount.toStringAsFixed(0)}'),
                        if (order.createdAt != null)
                          Text('Tanggal: ${order.createdAt!.toLocal().toString().split(' ')[0]}'),
                        const SizedBox(height: 8),
                        const Text('Items:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 2),
                          child: Text('${item.name} x${item.quantity} - Rp ${item.total.toStringAsFixed(0)}'),
                        )),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
          } catch (e) {
            print('Error parsing orders: $e'); // Debug log
            return Center(child: Text('Error parsing data: $e'));
          }
        },
      ),
    );
  }
}