import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String imageURL;
  final double price;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;

  Product({
    this.id,
    required this.imageURL,
    required this.price,
    required this.title,
    required this.description,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Firestore document to Product object
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      imageURL: map['imageURL'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Product object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'imageURL': imageURL,
      'price': price,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a copy of the product with some fields updated
  Product copyWith({
    String? id,
    String? imageURL,
    double? price,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      imageURL: imageURL ?? this.imageURL,
      price: price ?? this.price,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
