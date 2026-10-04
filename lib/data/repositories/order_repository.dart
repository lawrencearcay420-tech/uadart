import 'package:clothingapp/data/models/order.dart';

class OrderRepository {
  final List<Order> _orders = [];

  List<Order> getAllOrders() => List.unmodifiable(_orders);

  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      _orders[index] = Order(
        id: order.id,
        orderNumber: order.orderNumber,
        date: order.date,
        customerName: order.customerName,
        customerEmail: order.customerEmail,
        items: order.items,
        subtotal: order.subtotal,
        shipping: order.shipping,
        discount: order.discount,
        tax: order.tax,
        total: order.total,
        paymentMethod: order.paymentMethod,
        shippingAddress: order.shippingAddress,
        status: status,
      );
    }
  }

  List<Order> getOrdersForCustomer(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return [];
    return _orders
        .where(
          (order) =>
              order.customerEmail.trim().toLowerCase() == normalizedEmail,
        )
        .toList();
  }

  void loadOrders(List<Order> orders) {
    _orders.clear();
    _orders.addAll(orders);
  }
}
