import 'package:clothingapp/data/models/cart_item.dart';
import 'package:clothingapp/data/models/address.dart';

enum OrderStatus {
  processing,
  confirmed,
  packed,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get step => index;
}

class OrderItem {
  final String productId;
  final String name;
  final double priceAtPurchase;
  final String image;
  final String size;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.name,
    required this.priceAtPurchase,
    required this.image,
    required this.size,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
      image: json['image'] as String,
      size: json['size'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'priceAtPurchase': priceAtPurchase,
        'image': image,
        'size': size,
        'quantity': quantity,
      };

  double get totalPrice => priceAtPurchase * quantity;

  static OrderItem fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.productId,
      name: cartItem.productName,
      priceAtPurchase: cartItem.price,
      image: cartItem.image,
      size: cartItem.size,
      quantity: cartItem.quantity,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final DateTime date;
  final String customerName;
  final String customerEmail;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod;
  final Address shippingAddress;
  final OrderStatus status;

  Order({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.subtotal,
    required this.shipping,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    required this.paymentMethod,
    required this.shippingAddress,
    this.status = OrderStatus.processing,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      date: DateTime.parse(json['date'] as String),
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      items: (json['items'] as List)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      shippingAddress:
          Address.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      status: OrderStatus.values[json['status'] as int? ?? 0],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'date': date.toIso8601String(),
        'customerName': customerName,
        'customerEmail': customerEmail,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'shipping': shipping,
        'discount': discount,
        'tax': tax,
        'total': total,
        'paymentMethod': paymentMethod,
        'shippingAddress': shippingAddress.toJson(),
        'status': status.index,
      };
}
