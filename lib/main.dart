import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/app.dart';
import 'package:clothingapp/storage/local_storage.dart';
import 'package:clothingapp/storage/storage_migration.dart';
import 'package:clothingapp/data/repositories/order_repository.dart';
import 'package:clothingapp/data/repositories/user_repository.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';
import 'package:clothingapp/data/seed/promotions.dart';
import 'package:clothingapp/providers/auth_provider.dart';
import 'package:clothingapp/providers/product_provider.dart';
import 'package:clothingapp/providers/cart_provider.dart';
import 'package:clothingapp/providers/order_provider.dart';
import 'package:clothingapp/providers/wishlist_provider.dart';
import 'package:clothingapp/providers/theme_provider.dart';
import 'package:clothingapp/providers/ui_provider.dart';
import 'package:clothingapp/providers/account_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageMigration.initialize();
  await LocalStorage.init();

  final prefs = await SharedPreferences.getInstance();
  final storageRepository = StorageRepository(prefs);
  final productRepository = ProductProvider.createDefaultRepository();
  final userRepository = UserRepository();
  final orderRepository = OrderRepository();

  final user = await storageRepository.loadUser();
  userRepository.loadUser(user);

  final savedPromos = await storageRepository.loadPromos();
  if (savedPromos.isEmpty) {
    await storageRepository.savePromos(SeedPromotions.promos);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(userRepository, storageRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository, storageRepository),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider(storageRepository)),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderRepository, storageRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(storageRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AppThemeProvider(storageRepository),
        ),
        ChangeNotifierProvider(create: (_) => UIProvider()),
        ChangeNotifierProvider(create: (_) => AccountSettingsProvider(prefs)),
      ],
      child: const UnderAsawaApp(),
    ),
  );
}
