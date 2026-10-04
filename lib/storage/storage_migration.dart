import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

typedef JsonMap = Map<String, dynamic>;

class StorageMigration {
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateCart(prefs);
    await _migrateUser(prefs);
    await _migrateTheme(prefs);
    await _migrateProducts(prefs);
  }

  static Future<void> _migrateCart(SharedPreferences prefs) async {
    final legacyCart = prefs.getString('forme-cart');
    if (legacyCart == null || legacyCart.isEmpty) return;

    try {
      final decoded = jsonDecode(legacyCart);
      if (decoded is! Map<String, dynamic>) return;

      if (decoded['version'] == 1) return;

      if (decoded['items'] is List) {
        final items = decoded['items'] as List;
        if (items.isNotEmpty && items.first is Map) {
          final first = items.first as Map;
          if (first.containsKey('product')) {
          } else if (first.containsKey('productId')) {
            return;
          }
        }
      }
    } catch (_) {
      return;
    }

    final normalized = <String, dynamic>{
      'version': 2,
      'items': [],
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString('forme-cart', jsonEncode(normalized));
  }

  static Future<void> _migrateUser(SharedPreferences prefs) async {
    final userJson = prefs.getString('forme-user');
    if (userJson == null) {
      final demoUser = {
        'id': 'demo-user',
        'name': 'Demo User',
        'email': 'demo@user.com',
        'role': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString('forme-user', jsonEncode(demoUser));
    }
  }

  static Future<void> _migrateTheme(SharedPreferences prefs) async {
    final theme = prefs.getString('forme-theme');
    if (theme == null) {
      await prefs.setString('forme-theme', 'light');
    }
  }

  static Future<void> _migrateProducts(SharedPreferences prefs) async {
    final productsJson = prefs.getString('forme-products');
    if (productsJson == null || productsJson.isEmpty) return;
    try {
      final decoded = jsonDecode(productsJson);
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first as Map<String, dynamic>;
        if (first.containsKey('name')) {
          return;
        }
      }
    } catch (_) {
      return;
    }
  }

  static Future<void> saveProducts(List<dynamic> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('forme-products', jsonEncode(products));
  }
}
