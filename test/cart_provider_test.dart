import 'package:clothingapp/data/repositories/storage_repository.dart';
import 'package:clothingapp/data/seed/products.dart';
import 'package:clothingapp/providers/cart_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CartProvider cartProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    cartProvider = CartProvider(StorageRepository(preferences));
  });

  test('adds selected size and quantity to the bag', () {
    final product = SeedData.products.first;

    final added = cartProvider.addItem(product, 'M', product.color, 2);

    expect(added, isTrue);
    expect(cartProvider.items, hasLength(1));
    expect(cartProvider.items.single.size, 'M');
    expect(cartProvider.items.single.quantity, 2);
  });

  test('rejects a quantity above available size stock', () {
    final product = SeedData.products.first;

    final added = cartProvider.addItem(product, 'M', product.color, 6);

    expect(added, isFalse);
    expect(cartProvider.items, isEmpty);
  });

  test('prevents repeated adds from exceeding available stock', () {
    final product = SeedData.products.first;

    expect(cartProvider.addItem(product, 'M', product.color, 3), isTrue);
    expect(cartProvider.addItem(product, 'M', product.color, 3), isFalse);
    expect(cartProvider.items.single.quantity, 3);
  });
}
