import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clothingapp/storage/local_storage.dart';
import 'package:clothingapp/data/models/cart_item.dart';
import 'package:clothingapp/data/models/order.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/data/models/promo.dart';
import 'package:clothingapp/data/models/user.dart';
import 'package:clothingapp/data/models/wishlist_item.dart';
import 'package:clothingapp/data/models/address.dart';

class StorageRepository {
  final SharedPreferences _prefs;

  StorageRepository(this._prefs);

  Future<List<CartItem>> loadCart() async {
    final raw = _prefs.getString(LocalStorage.cartKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      final items = decoded['items'] as List<dynamic>;
      return items
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(List<CartItem> items) async {
    final data = {
      'version': 2,
      'items': items.map((i) => i.toJson()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(LocalStorage.cartKey, jsonEncode(data));
  }

  Future<List<Order>> loadOrders() async {
    final raw = _prefs.getString(LocalStorage.ordersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOrders(List<Order> orders) async {
    final data = orders.map((o) => o.toJson()).toList();
    await _prefs.setString(LocalStorage.ordersKey, jsonEncode(data));
  }

  Future<User?> loadUser() async {
    final raw = _prefs.getString(LocalStorage.userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return User.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    await _prefs.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
  }

  Future<void> removeUser() async {
    await _prefs.remove(LocalStorage.userKey);
  }

  Future<String> loadThemeMode() async {
    return _prefs.getString(LocalStorage.themeKey) ?? 'light';
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(LocalStorage.themeKey, mode);
  }

  Future<List<WishlistItem>> loadWishlist() async {
    final raw = _prefs.getString(LocalStorage.wishlistKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWishlist(List<WishlistItem> items) async {
    final data = items.map((i) => i.toJson()).toList();
    await _prefs.setString(LocalStorage.wishlistKey, jsonEncode(data));
  }

  Future<List<Address>> loadAddresses() async {
    final raw = _prefs.getString(LocalStorage.addressesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAddresses(List<Address> addresses) async {
    final data = addresses.map((a) => a.toJson()).toList();
    await _prefs.setString(LocalStorage.addressesKey, jsonEncode(data));
  }

  Future<List<Promo>> loadPromos() async {
    final raw = _prefs.getString(LocalStorage.promosKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Promo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePromos(List<Promo> promos) async {
    final data = promos.map((p) => p.toJson()).toList();
    await _prefs.setString(LocalStorage.promosKey, jsonEncode(data));
  }

  Future<List<Review>> loadReviews() async {
    final raw = _prefs.getString(LocalStorage.reviewsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReviews(List<Review> reviews) async {
    final data = reviews.map((r) => r.toJson()).toList();
    await _prefs.setString(LocalStorage.reviewsKey, jsonEncode(data));
  }

  Future<void> saveProducts(List<Product> products) async {
    final data = products.map((p) => p.toJson()).toList();
    await _prefs.setString(LocalStorage.productsKey, jsonEncode(data));
  }

  Future<List<Product>?> loadProducts() async {
    final raw = _prefs.getString(LocalStorage.productsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((product) => Product.fromJson(product as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> loadRecentSearches() async {
    final raw = _prefs.getString(LocalStorage.recentSearchesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e as String).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentSearches(List<String> searches) async {
    await _prefs.setString(
        LocalStorage.recentSearchesKey, jsonEncode(searches));
  }

  Future<bool> isNewsletterSubscribed() async {
    return _prefs.getBool(LocalStorage.newsletterKey) ?? false;
  }

  Future<void> setNewsletterSubscribed(bool value) async {
    await _prefs.setBool(LocalStorage.newsletterKey, value);
  }
}
