import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/currency.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/providers/cart_provider.dart';
import 'package:clothingapp/providers/product_provider.dart';
import 'package:clothingapp/providers/wishlist_provider.dart';
import 'package:clothingapp/widgets/common/app_back_button.dart';
import 'package:clothingapp/widgets/common/require_sign_in.dart';
import 'package:clothingapp/widgets/common/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = '';
  String _selectedColor = '';
  int _quantity = 1;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _product = _findProduct();
    if (_product != null) {
      _selectedSize = _product!.sizes.isNotEmpty ? _product!.sizes.first : '';
      _selectedColor = _product!.colors.isNotEmpty
          ? _product!.colors.first
          : '';
    }
  }

  Product? _findProduct() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    return provider.getById(widget.productId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _product ??= _findProduct();
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.getHorizontalPadding(context);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? AppColors.white : AppColors.black,
        ),
        body: const Center(child: Text('Product not found')),
      );
    }

    final hasStock = product.isInStock(_selectedSize);
    final isDesktop = Responsive.isDesktop(context);
    final inWishlist = context.watch<WishlistProvider>().isInWishlist(
      product.id,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.nearBlack : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.nearBlack : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: const AppBackButton(fallbackRoute: '/shop'),
        title: Text(
          'UNDER ASAWA',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            tooltip: inWishlist ? 'Remove from wishlist' : 'Add to wishlist',
            icon: Icon(
              inWishlist ? Icons.favorite : Icons.favorite_border,
              color: inWishlist
                  ? AppColors.error
                  : (isDark ? AppColors.white : AppColors.black),
            ),
            onPressed: () {
              context.read<WishlistProvider>().toggleWishlist(product);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : padding,
                vertical: isDesktop ? 36 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackToShop(context, isDark),
                  const SizedBox(height: 16),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 11,
                          child: _buildImageGallery(context, product),
                        ),
                        const SizedBox(width: 64),
                        Expanded(
                          flex: 9,
                          child: _buildProductInformation(
                            context,
                            product,
                            hasStock,
                            isDark,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageGallery(context, product),
                        const SizedBox(height: 28),
                        _buildProductInformation(
                          context,
                          product,
                          hasStock,
                          isDark,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInformation(
    BuildContext context,
    Product product,
    bool hasStock,
    bool isDark,
  ) {
    final mutedColor = isDark ? Colors.white70 : Colors.grey[700];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w600,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.name,
          style: TextStyle(
            fontSize: Responsive.isMobile(context) ? 28 : 36,
            height: 1.15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              CurrencyUtil.format(product.price),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            if (product.compareAtPrice != null) ...[
              const SizedBox(width: 10),
              Text(
                CurrencyUtil.format(product.compareAtPrice!),
                style: TextStyle(
                  fontSize: 15,
                  color: mutedColor,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 5),
            Text(
              '${product.rating} · ${product.reviewCount} reviews',
              style: TextStyle(fontSize: 13, color: mutedColor),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 22),
          child: Divider(height: 1),
        ),
        Text(
          product.description,
          style: TextStyle(fontSize: 15, height: 1.7, color: mutedColor),
        ),
        const SizedBox(height: 28),
        _buildSizeSelector(context, product),
        const SizedBox(height: 24),
        _buildColorSelector(context, product),
        const SizedBox(height: 24),
        _buildQuantitySelector(context, hasStock),
        const SizedBox(height: 28),
        _buildActionButtons(context, product, hasStock),
        const SizedBox(height: 32),
        _buildInfoSections(context, product),
      ],
    );
  }

  Widget _buildBackToShop(BuildContext context, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/shop');
          }
        },
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('Back to shop'),
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.white : AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageHeight = Responsive.isDesktop(context) ? 620.0 : 380.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: imageHeight,
        width: double.infinity,
        color: isDark ? AppColors.darkGrey : AppColors.offWhite,
        padding: const EdgeInsets.all(24),
        child: ProductImage(
          image: product.image,
          fit: BoxFit.contain,
          backgroundColor: isDark ? AppColors.darkGrey : AppColors.offWhite,
          iconColor: isDark ? Colors.white38 : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildSizeSelector(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Size',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: product.sizes.map((size) {
            final isSelected = _selectedSize == size;
            final inStock = product.isInStock(size);
            return ChoiceChip(
              label: Text(
                size,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (inStock
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.grey),
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: inStock
                  ? (_) => setState(() {
                      _selectedSize = size;
                      _quantity = 1;
                    })
                  : null,
              selectedColor: Colors.black,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: !inStock
                    ? Colors.grey
                    : (isSelected
                          ? Colors.black
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.grey[300]!)),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          }).toList(),
        ),
      const SizedBox(height: 8),
      _buildStockIndicator(product),
      ],
    );
  }

  Widget _buildStockIndicator(Product product) {
    final count = product.inventory[_selectedSize] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (count == 0) {
      return Text(
        'Sold Out',
        style: TextStyle(
          color: AppColors.error,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (count <= 2) {
      return Text(
        'Only $count left in stock',
        style: TextStyle(
          color: AppColors.warning,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Text(
      '$count in stock',
      style: TextStyle(
        color: isDark ? Colors.green[300] : Colors.green[700],
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildColorSelector(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: product.colors.map((color) {
            final isSelected = _selectedColor == color;
            return ChoiceChip(
              label: Text(
                color,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedColor = color),
              selectedColor: Colors.black,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: isSelected
                    ? Colors.black
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.grey[300]!),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(BuildContext context, bool hasStock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxQty = _product?.inventory[_selectedSize] ?? 1;
    return Row(
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _qtyButton(Icons.remove, () {
                if (_quantity > 1) setState(() => _quantity--);
              }, isDark),
              SizedBox(
                width: 48,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
              _qtyButton(Icons.add, () {
                if (_quantity < maxQty) setState(() => _quantity++);
              }, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey[100],
            borderRadius: BorderRadius.horizontal(
              left: Radius.zero,
              right: Radius.zero,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Product product,
    bool hasStock,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasStock
                ? () async {
                    final cart = context.read<CartProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    if (!await requireSignIn(context)) return;
                    if (!mounted) return;
                    if (_selectedSize.isEmpty) return;
                    final added = cart.addItem(
                      product,
                      _selectedSize,
                      _selectedColor,
                      _quantity,
                    );
                    if (!added) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'There is not enough stock available for that quantity.',
                          ),
                        ),
                      );
                      return;
                    }
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Added to bag')),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ADD TO BAG'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: hasStock
                ? () async {
                    final cart = context.read<CartProvider>();
                    final router = GoRouter.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    if (!await requireSignIn(context)) return;
                    if (!mounted) return;
                    if (_selectedSize.isEmpty) return;
                    final added = cart.addItem(
                      product,
                      _selectedSize,
                      _selectedColor,
                      _quantity,
                    );
                    if (!added) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'There is not enough stock available for that quantity.',
                          ),
                        ),
                      );
                      return;
                    }
                    router.go('/cart');
                  }
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('BUY NOW'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSections(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildAccordionSection('Description', product.description, isDark),
        _buildAccordionSection(
          'Material & Care',
          '${product.material}\n${product.care}',
          isDark,
        ),
        _buildAccordionSection(
          'Shipping & Returns',
          'Standard shipping: 3-5 business days.\nExpress shipping: 1-2 business days.\nFree shipping on orders over ₱2,000.\nReturns accepted within 30 days.',
          isDark,
        ),
        _buildAccordionSection(
          'Size Guide',
          'XS: 0-2\nS: 2-4\nM: 4-6\nL: 6-8\nXL: 8-10\nXXL: 10-12',
          isDark,
        ),
      ],
    );
  }

  Widget _buildAccordionSection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
      ],
    );
  }
}
