import 'package:flutter/material.dart';
import 'package:clothingapp/data/models/cart_item.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/data/models/promo.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';

class CartProvider extends ChangeNotifier {
  final StorageRepository _storage;
  List<CartItem> _items = [];
  Promo? _appliedPromo;
  bool _isLoading = true;

  CartProvider(this._storage) {
    _loadCart();
  }

  bool get isLoading => _isLoading;
  List<CartItem> get items => _items;
  Promo? get appliedPromo => _appliedPromo;
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);
  int get itemCount => totalQuantity;

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  static const double shippingThreshold = 2000;
  static const double shippingFee = 120;

  double get shipping => subtotal >= shippingThreshold ? 0 : shippingFee;

  double get discount =>
      _appliedPromo?.calculateDiscount(subtotal) ?? 0;

  double get tax => (subtotal - discount) * 0.08;

  double get total => subtotal + shipping - discount + tax;

  double get remainingForFreeShipping =>
      (shipping > 0) ? (shippingThreshold - subtotal).clamp(0, shippingThreshold) : 0;

  Future<void> _loadCart() async {
    _items = await _storage.loadCart();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveCart() async {
    await _storage.saveCart(_items);
  }

  bool addItem(Product product, String size, String color, int quantity) {
    final availableStock = product.inventory[size] ?? 0;
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id && item.size == size && item.color == color,
    );
    final currentQuantity =
        existingIndex == -1 ? 0 : _items[existingIndex].quantity;
    if (quantity < 1 || currentQuantity + quantity > availableStock) {
      return false;
    }

    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _items.add(CartItem.fromProduct(product, size, color, quantity));
    }
    _saveCart();
    notifyListeners();
    return true;
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
      }
      _saveCart();
      notifyListeners();
    }
  }

  void applyPromo(Promo promo) {
    _appliedPromo = promo;
    notifyListeners();
  }

  void removePromo() {
    _appliedPromo = null;
    notifyListeners();
  }

  bool validateStock() {
    return _items.every((item) => item.quantity <= (item.quantity));
  }

  void clearPurchased(List<CartItem> purchasedItems) {
    _items.removeWhere((item) => purchasedItems.contains(item));
    _saveCart();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
}
