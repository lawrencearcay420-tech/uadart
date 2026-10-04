import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/providers/product_provider.dart';
import 'package:clothingapp/widgets/common/glass_panel.dart';
import 'package:clothingapp/widgets/product/product_card.dart';
import 'package:clothingapp/widgets/common/app_back_button.dart';
import 'package:clothingapp/widgets/common/show_product_search.dart';

class ShopScreen extends StatefulWidget {
  final String initialCategory;
  final String initialSearch;

  const ShopScreen({
    super.key,
    this.initialCategory = 'All',
    this.initialSearch = '',
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late String _selectedCategory = widget.initialCategory;
  late String _searchQuery = widget.initialSearch;
  String _selectedSize = 'All';
  String _selectedColor = 'All';
  RangeValues _priceRange = const RangeValues(0, 5000);
  bool _inStockOnly = true;
  bool _showFilters = false;

  final List<String> _colors = [
    'All',
    'Black',
    'White',
    'Blue',
    'Gray',
    'Brown',
    'Pink',
    'Cream',
  ];
  final List<String> _sizes = [
    'All',
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'One Size',
  ];
  final List<String> _sortOptions = [
    'Featured',
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
    'Name',
    'Best Selling',
  ];

  String _sortBy = 'Featured';

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.getHorizontalPadding(context);
    final products = productProvider.isLoading
        ? null
        : _sortProducts(_applyFilters(productProvider.products));

    return Scaffold(
      backgroundColor: isDark ? AppColors.nearBlack : AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.nearBlack : AppColors.white,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'UNDER ASAWA',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.black,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search products',
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Responsive.isDesktop(context)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showFilters)
                  Flexible(
                    child: SizedBox(
                      width: 280,
                      child: _buildFilterSidebar(context),
                    ),
                  ),
                Expanded(child: _buildProductsGrid(context, products, padding)),
              ],
            )
          : _buildProductsGrid(context, products, padding),
    );
  }

  Widget _buildFilterSidebar(
    BuildContext context, {
    StateSetter? sheetSetState,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void updateState(VoidCallback update) {
      setState(update);
      sheetSetState?.call(() {});
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FILTER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  updateState(() {
                    _selectedCategory = 'All';
                    _selectedSize = 'All';
                    _selectedColor = 'All';
                    _priceRange = const RangeValues(0, 5000);
                    _inStockOnly = true;
                  });
                },
                child: Text(
                  'CLEAR ALL',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterSection(
            'Category',
            ['All', ..._categories()],
            _selectedCategory,
            (val) {
              updateState(() => _selectedCategory = val ?? 'All');
            },
          ),
          _buildFilterSection(
            'Color',
            _colors,
            _selectedColor,
            (val) => updateState(() => _selectedColor = val ?? 'All'),
          ),
          _buildFilterSection(
            'Size',
            _sizes,
            _selectedSize,
            (val) => updateState(() => _selectedSize = val ?? 'All'),
          ),
          _buildPriceFilter(
            context,
            (values) => updateState(() => _priceRange = values),
          ),
          _buildToggleSection(
            'In Stock Only',
            _inStockOnly,
            (val) => updateState(() => _inStockOnly = val ?? false),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (Responsive.isMobile(context)) {
                  Navigator.of(context).pop();
                } else {
                  updateState(() => _showFilters = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.black,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('APPLY FILTERS'),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _categories() {
    return ['Jackets', 'T-Shirts', 'Pants', 'Accessories'];
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options
              .map(
                (opt) => ChoiceChip(
                  label: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 12,
                      color: opt == selected
                          ? Colors.white
                          : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black87),
                    ),
                  ),
                  selected: opt == selected,
                  onSelected: (_) => onChanged(opt),
                  selectedColor: Colors.black,
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey[300]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPriceFilter(
    BuildContext context,
    ValueChanged<RangeValues> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price Range',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '₱${_priceRange.start.toInt()} - ₱${_priceRange.end.toInt()}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 5000,
          divisions: 50,
          activeColor: Colors.black,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildToggleSection(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.black,
        ),
      ],
    );
  }

  List<Product> _applyFilters(List<Product> products) {
    return products.where((p) {
      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty &&
          !p.name.toLowerCase().contains(query) &&
          !p.category.toLowerCase().contains(query) &&
          !p.description.toLowerCase().contains(query) &&
          !p.sku.toLowerCase().contains(query)) {
        return false;
      }
      if (_selectedCategory != 'All' && p.category != _selectedCategory) {
        return false;
      }
      if (_selectedColor != 'All' && p.color != _selectedColor) {
        return false;
      }
      if (_selectedSize != 'All' && !p.sizes.contains(_selectedSize)) {
        return false;
      }
      if (p.price < _priceRange.start || p.price > _priceRange.end) {
        return false;
      }
      if (_inStockOnly && p.stock == 0) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.of(products);
    switch (_sortBy) {
      case 'Newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'Price: Low to High':
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case 'Name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case 'Best Selling':
        sorted.sort((a, b) {
          final bestsellerOrder = (b.bestseller ? 1 : 0).compareTo(
            a.bestseller ? 1 : 0,
          );
          return bestsellerOrder != 0
              ? bestsellerOrder
              : b.reviewCount.compareTo(a.reviewCount);
        });
      case 'Featured':
        sorted.sort(
          (a, b) => (b.featured ? 1 : 0).compareTo(a.featured ? 1 : 0),
        );
    }
    return sorted;
  }

  Widget _buildProductsGrid(
    BuildContext context,
    List<Product>? products,
    double padding,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 32, padding, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCategory == 'All' ? 'Shop all' : _selectedCategory,
                  style: TextStyle(
                    color: isDark
                        ? const Color.fromARGB(255, 248, 248, 248)
                        : AppColors.black,
                    fontSize: Responsive.isMobile(context) ? 28 : 36,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Thoughtful essentials, made for everyday wear.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                if (_searchQuery.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  InputChip(
                    label: Text('Search: ${_searchQuery.trim()}'),
                    onDeleted: () => setState(() => _searchQuery = ''),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 16, padding, 12),
            child: Row(
              children: [
                Text(
                  '${products?.length ?? 0} items',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  'Sort by',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: _sortOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _sortBy = val ?? 'Featured'),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.black,
                    fontSize: 13,
                  ),
                  underline: const SizedBox(),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    if (Responsive.isDesktop(context)) {
                      setState(() => _showFilters = !_showFilters);
                    } else {
                      _showMobileFilters(context);
                    }
                  },
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : AppColors.black,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey.shade400,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: Divider(height: 1)),
        if (products == null)
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => GlassPanel(
                  borderRadius: 16,
                  child: const SizedBox.expand(),
                ),
                childCount: 6,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.getGridColumns(context),
                childAspectRatio: Responsive.getProductCardAspectRatio(context),
                crossAxisSpacing: Responsive.scalePadding(context, 20),
                mainAxisSpacing: Responsive.scalePadding(context, 24),
              ),
            ),
          )
        else if (products.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.go('/product/${product.id}'),
                  showQuickAdd: true,
                );
              }, childCount: products.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.getGridColumns(context),
                childAspectRatio: Responsive.getProductCardAspectRatio(context),
                crossAxisSpacing: Responsive.scalePadding(context, 20),
                mainAxisSpacing: Responsive.scalePadding(context, 24),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 64),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 40,
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try another search or adjust your filters.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height:
                30 +
                MediaQuery.of(context).padding.bottom +
                (Responsive.isDesktop(context)
                    ? 0
                    : MediaQuery.of(context).viewInsets.bottom) +
                kBottomNavigationBarHeight,
          ),
        ),
      ],
    );
  }

  Future<void> _showMobileFilters(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, sheetSetState) => SafeArea(
          child: _buildFilterSidebar(
            sheetContext,
            sheetSetState: sheetSetState,
          ),
        ),
      ),
    );
  }

  Future<void> _showSearch() async {
    final query = await showProductSearch(context, initialQuery: _searchQuery);
    if (query != null && mounted) {
      setState(() => _searchQuery = query.trim());
    }
  }
}
