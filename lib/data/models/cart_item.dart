import 'package:clothingapp/data/models/product.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String image;
  final double price;
  final String size;
  final String color;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.image,
    required this.price,
    required this.size,
    required this.color,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      productId: productId,
      productName: productName,
      image: image,
      price: price,
      size: size,
      color: color,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      size: json['size'] as String,
      color: json['color'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'image': image,
        'price': price,
        'size': size,
        'color': color,
        'quantity': quantity,
      };

  static CartItem fromProduct(Product product, String size, String color,
      int quantity) {
    return CartItem(
      id: '${product.id}_${size}_$color',
      productId: product.id,
      productName: product.name,
      image: product.image,
      price: product.price,
      size: size,
      color: color,
      quantity: quantity,
    );
  }
}
