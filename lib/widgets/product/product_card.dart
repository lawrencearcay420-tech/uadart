import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/currency.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/providers/cart_provider.dart';
import 'package:clothingapp/providers/wishlist_provider.dart';
import 'package:clothingapp/widgets/common/require_sign_in.dart';
import 'package:clothingapp/widgets/common/product_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistToggle;
  final bool showWishlist;
  final bool showQuickAdd;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistToggle,
    this.showWishlist = true,
    this.showQuickAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSale = product.compareAtPrice != null;
    final isOutOfStock = product.stock == 0;
    final isInWishlist = context.watch<WishlistProvider>().isInWishlist(
      product.id,
    );
    final nameFontSize = Responsive.scaleFontSize(context, 14);
    final priceFontSize = Responsive.scaleFontSize(context, 16);
    final badgeFontSize = Responsive.scaleFontSize(context, 10);
    final stockFontSize = Responsive.scaleFontSize(context, 12);

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: Card(
        color: isDark ? AppColors.darkGrey : Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.white,
                  child: ProductImage(
                    image: product.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.contain,
                    backgroundColor: Colors.grey[100],
                    iconColor: Colors.grey[500],
                  ),
                ),
                if (hasSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                       child: Text(
                        'SALE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: badgeFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (showWishlist)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (onWishlistToggle != null) {
                            onWishlistToggle!();
                          } else {
                            context.read<WishlistProvider>().toggleWishlist(
                              product,
                            );
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.05,
                                ),
                                spreadRadius: 0,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: isInWishlist
                                ? AppColors.error
                                : (isDark ? Colors.white : AppColors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isOutOfStock)
                  Positioned(
                    top: 8,
                    right: showWishlist ? 48 : 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SOLD OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.scalePadding(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    product.name,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (hasSale)
                    Text(
                      '${CurrencyUtil.format(product.compareAtPrice!)} → ${CurrencyUtil.format(product.price)}',
                      style: TextStyle(
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                    )
                  else
                    Text(
                      CurrencyUtil.format(product.price),
                      style: TextStyle(
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                    ),
                  if (hasSale)
                    Text(
                      '${((product.compareAtPrice! - product.price) / product.compareAtPrice! * 100).toInt()}% OFF',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating}',
                        style: TextStyle(
                          fontSize: Responsive.scaleFontSize(context, 12),
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isOutOfStock
                          ? 'Sold out'
                          : product.stock <= 2
                              ? 'Only ${product.stock} left in stock'
                              : '${product.stock} in stock',
                       style: TextStyle(
                        fontSize: stockFontSize,
                        height: 1.2,
                        color: isOutOfStock
                            ? AppColors.error
                            : product.stock <= 2
                                ? AppColors.warning
                                : (isDark ? Colors.green[300] : Colors.green[700]),
                        fontWeight: isOutOfStock || product.stock <= 2
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showQuickAdd)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: TextButton.icon(
                    onPressed: isOutOfStock
                        ? null
                        : () => _showQuickAdd(context),
                    icon: const Icon(Icons.shopping_cart, size: 14),
                    label: const Text(
                      'QUICK ADD',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuickAdd(BuildContext context) async {
    if (!await requireSignIn(context) || !context.mounted) return;

    final availableSizes = product.sizes
        .where(product.isInStock)
        .toList();
    if (availableSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is currently unavailable.')),
      );
      return;
    }

    final selection = await showModalBottomSheet<({String size, int quantity})>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        var selectedSize = availableSizes.first;
        var quantity = 1;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final maxQuantity = product.inventory[selectedSize] ?? 0;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose size and quantity',
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(product.name),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: availableSizes
                          .map(
                            (size) => ChoiceChip(
                              label: Text(size),
                              selected: selectedSize == size,
                              onSelected: (_) => setSheetState(() {
                                selectedSize = size;
                                quantity = 1;
                              }),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Quantity'),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Decrease quantity',
                          onPressed: quantity > 1
                              ? () => setSheetState(() => quantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$quantity',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Increase quantity',
                          onPressed: quantity < maxQuantity
                              ? () => setSheetState(() => quantity++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        Text('$maxQuantity available'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(
                          (size: selectedSize, quantity: quantity),
                        ),
                        child: const Text('ADD TO BAG'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selection == null || !context.mounted) return;
    if (!await requireSignIn(context) || !context.mounted) return;
    final added = context.read<CartProvider>().addItem(
      product,
      selection.size,
      product.color,
      selection.quantity,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${selection.quantity} × ${product.name} (${selection.size}) added to your bag.'
              : 'There is not enough stock available for that quantity.',
        ),
      ),
    );
  }
}
