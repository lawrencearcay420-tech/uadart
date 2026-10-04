import 'package:clothingapp/data/models/review.dart';

export 'package:clothingapp/data/models/review.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? compareAtPrice;
  final String color;
  final String description;
  final String details;
  final String material;
  final String care;
  final List<String> sizes;
  final int stock;
  final Map<String, int> inventory;
  final String? badge;
  final String image;
  final String sku;
  final double rating;
  final int reviewCount;
  final bool featured;
  final bool bestseller;
  final bool archived;
  final DateTime createdAt;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.compareAtPrice,
    required this.color,
    required this.description,
    required this.details,
    required this.material,
    required this.care,
    required this.sizes,
    required this.stock,
    required this.inventory,
    this.badge,
    required this.image,
    required this.sku,
    this.rating = 0,
    this.reviewCount = 0,
    this.featured = false,
    this.bestseller = false,
    this.archived = false,
    DateTime? createdAt,
    List<Review>? reviews,
  })  : createdAt = createdAt ?? DateTime.now(),
        reviews = reviews ?? [];

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      compareAtPrice: json['compareAtPrice'] != null
          ? (json['compareAtPrice'] as num).toDouble()
          : null,
      color: json['color'] as String,
      description: json['description'] as String,
      details: json['details'] as String,
      material: json['material'] as String,
      care: json['care'] as String,
      sizes: List<String>.from(json['sizes'] as List),
      stock: json['stock'] as int? ?? 0,
      inventory: Map<String, int>.from(json['inventory'] as Map? ?? {}),
      badge: json['badge'] as String?,
      image: json['image'] as String,
      sku: json['sku'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      featured: json['featured'] as bool? ?? false,
      bestseller: json['bestseller'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
      'color': color,
      'description': description,
      'details': details,
      'material': material,
      'care': care,
      'sizes': sizes,
      'stock': stock,
      'inventory': inventory,
      if (badge != null) 'badge': badge,
      'image': image,
      'sku': sku,
      'rating': rating,
      'reviewCount': reviewCount,
      'featured': featured,
      'bestseller': bestseller,
      'archived': archived,
      'createdAt': createdAt.toIso8601String(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? compareAtPrice,
    String? color,
    String? description,
    String? details,
    String? material,
    String? care,
    List<String>? sizes,
    int? stock,
    Map<String, int>? inventory,
    String? badge,
    String? image,
    String? sku,
    double? rating,
    int? reviewCount,
    bool? featured,
    bool? bestseller,
    bool? archived,
    DateTime? createdAt,
    List<Review>? reviews,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      color: color ?? this.color,
      description: description ?? this.description,
      details: details ?? this.details,
      material: material ?? this.material,
      care: care ?? this.care,
      sizes: sizes ?? this.sizes,
      stock: stock ?? this.stock,
      inventory: inventory ?? this.inventory,
      badge: badge ?? this.badge,
      image: image ?? this.image,
      sku: sku ?? this.sku,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      featured: featured ?? this.featured,
      bestseller: bestseller ?? this.bestseller,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      reviews: reviews ?? this.reviews,
    );
  }

  List<String> get colors => [color];

  String get totalPrice => '\$${price.toStringAsFixed(2)}';

  bool isInStock(String size) {
    final count = inventory[size] ?? 0;
    return count > 0;
  }

  bool isLowStock(String size) {
    final count = inventory[size] ?? 0;
    return count > 0 && count <= 2;
  }
}
