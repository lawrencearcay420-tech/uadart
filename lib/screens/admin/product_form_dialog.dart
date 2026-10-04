import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/data/seed/categories.dart';
import 'package:clothingapp/widgets/common/product_image.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _comparePriceController;
  late final TextEditingController _colorController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _detailsController;
  late final TextEditingController _materialController;
  late final TextEditingController _careController;
  late final TextEditingController _sizesController;
  late final TextEditingController _inventoryController;
  late final TextEditingController _badgeController;
  late String _category;
  late bool _featured;
  late bool _bestseller;
  String? _inventoryError;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _comparePriceController = TextEditingController(
      text: product?.compareAtPrice?.toString() ?? '',
    );
    _colorController = TextEditingController(text: product?.color ?? '');
    _imageController = TextEditingController(text: product?.image ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _detailsController = TextEditingController(text: product?.details ?? '');
    _materialController = TextEditingController(text: product?.material ?? '');
    _careController = TextEditingController(text: product?.care ?? '');
    _sizesController = TextEditingController(
      text: product?.sizes.join(', ') ?? 'S, M, L, XL',
    );
    _inventoryController = TextEditingController(
      text: product == null
          ? 'S:10, M:10, L:10, XL:10'
          : product.sizes
                .map((size) => '$size:${product.inventory[size] ?? 0}')
                .join(', '),
    );
    _badgeController = TextEditingController(text: product?.badge ?? '');
    _category = product?.category ?? AppCategories.categories.first.name;
    _featured = product?.featured ?? false;
    _bestseller = product?.bestseller ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _colorController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _detailsController.dispose();
    _materialController.dispose();
    _careController.dispose();
    _sizesController.dispose();
    _inventoryController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final sizes = _sizesController.text
        .split(',')
        .map((size) => size.trim())
        .where((size) => size.isNotEmpty)
        .toSet()
        .toList();
    final inventory = <String, int>{};
    final inventorySizes = <String>[];
    for (final entry in _inventoryController.text.split(',')) {
      final parts = entry.trim().split(':');
      if (parts.length != 2 || parts.first.trim().isEmpty) {
        setState(() {
          _inventoryError =
              'Use the format SIZE:quantity, for example S:10, M:5.';
        });
        return;
      }
      final quantity = int.tryParse(parts[1].trim());
      if (quantity == null || quantity < 0) {
        setState(() {
          _inventoryError =
              'Stock quantities must be zero or a positive number.';
        });
        return;
      }
      final size = parts.first.trim();
      inventorySizes.add(size);
      inventory[size] = quantity;
    }
    if (sizes.isEmpty ||
        inventorySizes.toSet().length != inventorySizes.length ||
        inventory.keys.toSet().difference(sizes.toSet()).isNotEmpty ||
        sizes.toSet().difference(inventory.keys.toSet()).isNotEmpty) {
      setState(() {
        _inventoryError =
            'Enter stock for every size, with no duplicate sizes.';
      });
      return;
    }

    final product = widget.product;
    Navigator.of(context).pop(
      Product(
        id: product?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _category,
        price: double.parse(_priceController.text.trim()),
        compareAtPrice: _comparePriceController.text.trim().isEmpty
            ? null
            : double.parse(_comparePriceController.text.trim()),
        color: _colorController.text.trim(),
        description: _descriptionController.text.trim(),
        details: _detailsController.text.trim(),
        material: _materialController.text.trim(),
        care: _careController.text.trim(),
        sizes: sizes,
        stock: inventory.values.fold<int>(0, (total, value) => total + value),
        inventory: inventory,
        badge: _badgeController.text.trim().isEmpty
            ? null
            : _badgeController.text.trim(),
        image: _imageController.text.trim(),
        sku: _skuController.text.trim(),
        featured: _featured,
        bestseller: _bestseller,
        createdAt: product?.createdAt,
        reviews: product?.reviews,
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  String? _priceValidator(String? value) {
    final price = double.tryParse(value?.trim() ?? '');
    return price == null || price <= 0
        ? 'Enter a price greater than zero.'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.black;
    final categories = AppCategories.categories.map((c) => c.name).toList();
    if (!categories.contains(_category)) categories.add(_category);

    return AlertDialog(
      title: Text(widget.product == null ? 'Add product' : 'Edit product'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field('Product name', _nameController, validator: _required),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        'Price',
                        _priceController,
                        validator: _priceValidator,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        'Compare-at price (optional)',
                        _comparePriceController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final price = double.tryParse(value.trim());
                          return price == null || price <= 0
                              ? 'Enter a valid positive price.'
                              : null;
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        'Color',
                        _colorController,
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        'SKU',
                        _skuController,
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(
                  'Image URL or asset path',
                  _imageController,
                  validator: _required,
                  hint: 'https://... or assets/...',
                ),
                if (_imageController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: ProductImage(
                      image: _imageController.text.trim(),
                      backgroundColor: isDark
                          ? AppColors.nearBlack
                          : AppColors.offWhite,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _field(
                  'Description',
                  _descriptionController,
                  validator: _required,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _field('Product details', _detailsController, maxLines: 2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field('Material', _materialController)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field('Care instructions', _careController),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(
                  'Sizes (comma-separated)',
                  _sizesController,
                  validator: _required,
                  hint: 'S, M, L, XL',
                ),
                const SizedBox(height: 12),
                _field(
                  'Inventory by size',
                  _inventoryController,
                  validator: _required,
                  hint: 'S:10, M:5, L:0',
                ),
                if (_inventoryError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _inventoryError!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 12),
                _field('Badge (optional)', _badgeController),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Featured', style: TextStyle(color: foreground)),
                  value: _featured,
                  onChanged: (value) => setState(() => _featured = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Bestseller',
                    style: TextStyle(color: foreground),
                  ),
                  value: _bestseller,
                  onChanged: (value) => setState(() => _bestseller = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save product')),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
      onChanged: label == 'Image URL or asset path'
          ? (_) => setState(() {})
          : null,
    );
  }
}
