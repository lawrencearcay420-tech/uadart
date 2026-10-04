import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:clothingapp/data/models/order.dart';
import 'package:clothingapp/data/models/cart_item.dart';
import 'package:clothingapp/data/models/address.dart';
import 'package:clothingapp/data/models/user.dart';
import 'package:clothingapp/data/repositories/order_repository.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;
  final StorageRepository _storage;
  bool _isLoading = true;

  OrderProvider(this._repository, this._storage) {
    _loadOrders();
  }

  bool get isLoading => _isLoading;
  List<Order> get orders => _repository.getAllOrders();

  Future<void> _loadOrders() async {
    final loaded = await _storage.loadOrders();
    _repository.loadOrders(loaded);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveOrders() async {
    await _storage.saveOrders(_repository.getAllOrders());
  }

  Future<Order> createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double shipping,
    required double discount,
    required double tax,
    required double total,
    required String paymentMethod,
    required Address shippingAddress,
    required User customer,
  }) async {
    final orderItems =
        items.map((i) => OrderItem.fromCartItem(i)).toList();

    final order = Order(
      id: const Uuid().v4(),
      orderNumber: 'UA-${DateTime.now().year}-${_generateOrderNumber()}',
      date: DateTime.now(),
      customerName: customer.name,
      customerEmail: customer.email,
      items: orderItems,
      subtotal: subtotal,
      shipping: shipping,
      discount: discount,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      status: OrderStatus.processing,
    );

    _repository.addOrder(order);
    await _saveOrders();
    notifyListeners();
    return order;
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    return '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  Order? getOrderById(String id) => _repository.getById(id);

  List<Order> getOrdersForCustomer(String email) =>
      _repository.getOrdersForCustomer(email);

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    _repository.updateOrderStatus(orderId, status);
    await _saveOrders();
    notifyListeners();
  }
}
