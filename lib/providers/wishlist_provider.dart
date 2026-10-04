import 'package:flutter/material.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/data/models/wishlist_item.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';

class WishlistProvider extends ChangeNotifier {
  final StorageRepository _storage;
  List<WishlistItem> _items = [];
  bool _isLoading = true;

  WishlistProvider(this._storage) {
    _loadWishlist();
  }

  bool get isLoading => _isLoading;
  List<WishlistItem> get items => _items;

  bool isInWishlist(String productId) =>
      _items.any((item) => item.productId == productId);

  Future<void> _loadWishlist() async {
    _items = await _storage.loadWishlist();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    await _storage.saveWishlist(_items);
  }

  Future<void> addToWishlist(Product product) async {
    if (isInWishlist(product.id)) return;

    _items.add(
      WishlistItem(
        productId: product.id,
        productName: product.name,
        image: product.image,
        price: product.price,
      ),
    );
    await _saveWishlist();
    notifyListeners();
  }

  Future<void> removeFromWishlist(String productId) async {
    _items.removeWhere((item) => item.productId == productId);
    await _saveWishlist();
    notifyListeners();
  }

  Future<void> clearWishlist() async {
    if (_items.isEmpty) return;
    _items.clear();
    await _saveWishlist();
    notifyListeners();
  }

  Future<void> toggleWishlist(Product product) async {
    if (isInWishlist(product.id)) {
      await removeFromWishlist(product.id);
    } else {
      await addToWishlist(product);
    }
  }
}
