// lib/Models/order.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_product.dart';

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double total;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] ?? 0.0),
      quantity: map['quantity'] ?? 0,
      total: (map['total'] is int) ? (map['total'] as int).toDouble() : (map['total'] ?? 0.0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }
}

class AppOrder {
  final String id;
  final String userId;
  final String userEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;

  AppOrder({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.createdAt,
  });

  factory AppOrder.fromMap(Map<String, dynamic> map, String id) {
    return AppOrder(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      totalAmount: (map['totalAmount'] is int) ? (map['totalAmount'] as int).toDouble() : (map['totalAmount'] ?? 0.0),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}