import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clothingapp/app.dart';
import 'package:clothingapp/data/repositories/order_repository.dart';
import 'package:clothingapp/data/repositories/user_repository.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';
import 'package:clothingapp/providers/auth_provider.dart';
import 'package:clothingapp/providers/product_provider.dart';
import 'package:clothingapp/providers/cart_provider.dart';
import 'package:clothingapp/providers/order_provider.dart';
import 'package:clothingapp/providers/wishlist_provider.dart';
import 'package:clothingapp/providers/theme_provider.dart';
import 'package:clothingapp/providers/ui_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final storageRepository = StorageRepository(prefs);
    final productRepository = ProductProvider.createDefaultRepository();
    final userRepository = UserRepository();
    final orderRepository = OrderRepository();
    userRepository.loadUser(await storageRepository.loadUser());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(userRepository, storageRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => ProductProvider(productRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => CartProvider(storageRepository),
          ),
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
        ],
        child: const UnderAsawaApp(),
      ),
    );

    expect(find.text('MINIMAL PIECES.'), findsOneWidget);
  });
}
