import 'package:flutter/material.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/data/seed/products.dart';
import 'package:clothingapp/data/repositories/product_repository.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;
  final StorageRepository? _storage;
  bool _isLoading = true;

  ProductProvider(this._repository, [this._storage]) {
    _loadProducts();
  }

  bool get isLoading => _isLoading;
  List<Product> get products => _repository.getAllProducts();
  List<Product> get allProducts => _repository.getAllProductsIncludingArchived();
  List<Product> get featuredProducts => _repository.getFeaturedProducts();
  List<Product> get bestSellers => _repository.getBestSellers();
  ProductRepository get repository => _repository;

  Future<void> _loadProducts() async {
    final savedProducts = await _storage?.loadProducts();
    if (savedProducts != null) {
      _repository.replaceAll(savedProducts);
    }
    _isLoading = false;
    notifyListeners();
  }

  List<Product> getByCategory(String category) =>
      _repository.getByCategory(category);

  Product? getById(String id) => _repository.getById(id);

  List<Product> search(String query) => _repository.search(query);

  Future<void> addProduct(Product product) async {
    final previousProducts = allProducts;
    _repository.addProduct(product);
    try {
      await _saveProducts();
    } catch (_) {
      _repository.replaceAll(previousProducts);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final previousProducts = allProducts;
    _repository.updateProduct(product);
    try {
      await _saveProducts();
    } catch (_) {
      _repository.replaceAll(previousProducts);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> adjustStock(String productId, Map<String, int> newInventory) async {
    final product = _repository.getById(productId);
    if (product == null) throw Exception('Product not found');
    final totalStock = newInventory.values.fold<int>(0, (sum, v) => sum + v);
    final updated = product.copyWith(
      stock: totalStock,
      inventory: newInventory,
    );
    await updateProduct(updated);
  }

  Future<void> deleteProduct(String id) async {
    final previousProducts = allProducts;
    _repository.deleteProduct(id);
    try {
      await _saveProducts();
    } catch (_) {
      _repository.replaceAll(previousProducts);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    await _storage?.saveProducts(allProducts);
  }

  static ProductRepository createDefaultRepository() {
    final products = SeedData.products.map((p) => p).toList();
    return ProductRepository(products);
  }
}
