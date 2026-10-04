import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static LocalStorage? _instance;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _instance = LocalStorage._internal();
  }

  LocalStorage._internal();

  factory LocalStorage() {
    if (_instance == null) {
      throw Exception('LocalStorage must be initialized with init() first');
    }
    return _instance!;
  }

  static LocalStorage get instance {
    if (_instance == null) {
      throw Exception('LocalStorage must be initialized with init() first');
    }
    return _instance!;
  }

  Future<T?> get<T>(String key) async {
    final value = _prefs?.getString(key);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded as T?;
    } catch (_) {
      return null;
    }
  }

  Future<void> set(String key, dynamic value) async {
    final jsonString = jsonEncode(value);
    await _prefs?.setString(key, jsonString);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }

  Future<bool> containsKey(String key) async {
    return _prefs?.containsKey(key) ?? false;
  }

  static const String productsKey = 'forme-products';
  static const String cartKey = 'forme-cart';
  static const String ordersKey = 'forme-orders';
  static const String wishlistKey = 'forme-wishlist';
  static const String addressesKey = 'forme-addresses';
  static const String promosKey = 'forme-promos';
  static const String reviewsKey = 'forme-reviews';
  static const String userKey = 'forme-user';
  static const String themeKey = 'forme-theme';
  static const String newsletterKey = 'forme-newsletter';
  static const String recentSearchesKey = 'forme-recent-searches';
  static const String settingsKey = 'forme-settings';

  static const String legacyCartKey = 'forme-cart';
}
