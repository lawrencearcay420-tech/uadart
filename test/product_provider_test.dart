import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/data/repositories/product_repository.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';
import 'package:clothingapp/providers/product_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists product create, update, and delete operations', () async {
    final storage = StorageRepository(await SharedPreferences.getInstance());
    final provider = ProductProvider(ProductRepository([]), storage);
    await _waitForLoad(provider);

    final created = _product(name: 'Test jacket');
    await provider.addProduct(created);
    expect(provider.getById(created.id)?.name, 'Test jacket');

    final updated = created.copyWith(name: 'Updated jacket');
    await provider.updateProduct(updated);
    expect(provider.getById(created.id)?.name, 'Updated jacket');

    provider.dispose();
    final reloaded = ProductProvider(ProductRepository([]), storage);
    await _waitForLoad(reloaded);
    expect(reloaded.getById(created.id)?.name, 'Updated jacket');

    await reloaded.deleteProduct(created.id);
    reloaded.dispose();
    final afterDelete = ProductProvider(ProductRepository([]), storage);
    await _waitForLoad(afterDelete);
    expect(afterDelete.allProducts, isEmpty);
    afterDelete.dispose();
  });
}

Future<void> _waitForLoad(ProductProvider provider) async {
  while (provider.isLoading) {
    await Future<void>.delayed(Duration.zero);
  }
}

Product _product({required String name}) {
  return Product(
    id: 'test-product',
    name: name,
    category: 'Jackets',
    price: 1000,
    color: 'Black',
    description: 'Test description',
    details: 'Test details',
    material: 'Cotton',
    care: 'Wash cold',
    sizes: const ['S', 'M'],
    stock: 10,
    inventory: const {'S': 5, 'M': 5},
    image: 'assets/BJACKET.jpeg',
    sku: 'TEST-001',
  );
}
