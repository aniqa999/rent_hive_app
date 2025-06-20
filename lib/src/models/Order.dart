import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final String productImage;
  final double productPrice;
  final String productDescription;
  final String productCategory;
  final DateTime createdAt;
  final String status; // 'cart', 'ordered', 'delivered', etc.

  Order({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.productPrice,
    required this.productDescription,
    required this.productCategory,
    required this.createdAt,
    this.status = 'cart',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'productPrice': productPrice,
      'productDescription': productDescription,
      'productCategory': productCategory,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      productTitle: map['productTitle'] ?? '',
      productImage: map['productImage'] ?? '',
      productPrice: (map['productPrice'] ?? 0.0).toDouble(),
      productDescription: map['productDescription'] ?? '',
      productCategory: map['productCategory'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'cart',
    );
  }
}
