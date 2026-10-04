import 'package:clothingapp/data/models/product.dart';

class ProductRepository {
  final List<Product> _products;

  ProductRepository(this._products);

  List<Product> getAllProductsIncludingArchived() =>
      List.unmodifiable(_products);

  List<Product> getAllProducts() =>
      _products.where((p) => !p.archived).toList();

  List<Product> getFeaturedProducts() =>
      _products.where((p) => p.featured && !p.archived).toList();

  List<Product> getBestSellers() =>
      _products.where((p) => p.bestseller && !p.archived).toList();

  List<Product> getByCategory(String category) => _products
      .where((p) => p.category == category && !p.archived)
      .toList();

  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> search(String query) {
    final lower = query.toLowerCase();
    return _products
        .where((p) =>
            !p.archived &&
            (p.name.toLowerCase().contains(lower) ||
                p.category.toLowerCase().contains(lower) ||
                p.description.toLowerCase().contains(lower) ||
                p.sku.toLowerCase().contains(lower)))
        .toList();
  }

  void addProduct(Product product) {
    _products.add(product);
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
  }

  void replaceAll(List<Product> products) {
    _products
      ..clear()
      ..addAll(products);
  }
}
