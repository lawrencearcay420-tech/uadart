import 'package:uuid/uuid.dart';

class WishlistItem {
  final String id;
  final String productId;
  final String productName;
  final String image;
  final double price;
  final DateTime addedAt;

  WishlistItem({
    String? id,
    required this.productId,
    required this.productName,
    required this.image,
    required this.price,
    DateTime? addedAt,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String? ?? const Uuid().v4(),
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'image': image,
        'price': price,
        'addedAt': addedAt.toIso8601String(),
      };
}
