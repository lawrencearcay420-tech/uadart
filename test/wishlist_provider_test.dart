import 'package:clothingapp/data/repositories/storage_repository.dart';
import 'package:clothingapp/data/seed/products.dart';
import 'package:clothingapp/providers/wishlist_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WishlistProvider wishlistProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    wishlistProvider = WishlistProvider(StorageRepository(preferences));
    while (wishlistProvider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
  });

  tearDown(() {
    wishlistProvider.dispose();
  });

  test(
    'saves products, prevents duplicates, and removes saved products',
    () async {
      final product = SeedData.products.first;

      await wishlistProvider.addToWishlist(product);
      await wishlistProvider.addToWishlist(product);

      expect(wishlistProvider.items, hasLength(1));
      expect(wishlistProvider.items.single.productName, product.name);

      await wishlistProvider.removeFromWishlist(product.id);

      expect(wishlistProvider.items, isEmpty);
    },
  );

  test('clears all saved products in one operation', () async {
    await wishlistProvider.addToWishlist(SeedData.products[0]);
    await wishlistProvider.addToWishlist(SeedData.products[1]);

    await wishlistProvider.clearWishlist();

    expect(wishlistProvider.items, isEmpty);
  });
}
