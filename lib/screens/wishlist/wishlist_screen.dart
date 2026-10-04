import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/backgrounds/page_background.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/currency.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/data/models/wishlist_item.dart';
import 'package:clothingapp/providers/product_provider.dart';
import 'package:clothingapp/providers/wishlist_provider.dart';
import 'package:clothingapp/widgets/common/app_back_button.dart';
import 'package:clothingapp/widgets/common/loading_state.dart';
import 'package:clothingapp/widgets/common/product_image.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future<void> _clearWishlist() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear saved items?'),
        content: const Text('This will remove every item from your wishlist.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear wishlist'),
          ),
        ],
      ),
    );
    if (shouldClear != true || !mounted) return;

    try {
      await context.read<WishlistProvider>().clearWishlist();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to clear wishlist: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final products = context.watch<ProductProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = Responsive.getHorizontalPadding(context);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.nearBlack : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppBackButton(fallbackRoute: '/shop'),
        title: const Text(
          'Wishlist',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (wishlist.items.isNotEmpty)
            TextButton.icon(
              onPressed: _clearWishlist,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear all'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: PageBackground(
        intensity: 0.2,
        child: wishlist.isLoading || products.isLoading
            ? const LoadingState(message: 'Loading your saved items...')
            : wishlist.items.isEmpty
            ? _emptyWishlist(context, isDark)
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  28,
                  horizontalPadding,
                  36,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeading(wishlist.items.length, isDark),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 1000
                                ? 4
                                : constraints.maxWidth >= 680
                                ? 3
                                : constraints.maxWidth >= 420
                                ? 2
                                : 1;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: wishlist.items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: columns == 1
                                        ? 1.35
                                        : columns == 2
                                        ? 0.58
                                        : columns == 3
                                        ? 0.60
                                        : 0.68,
                                  ),
                              itemBuilder: (context, index) {
                                final savedItem = wishlist.items[index];
                                final product = products.getById(
                                  savedItem.productId,
                                );
                                return _wishlistCard(
                                  context,
                                  savedItem,
                                  product?.category,
                                  isDark,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeading(int itemCount, bool isDark) {
    final foreground = isDark ? AppColors.white : AppColors.black;
    final muted = isDark ? Colors.white60 : Colors.grey[600];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your saved pieces',
                style: TextStyle(
                  color: foreground,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Keep the styles you love close at hand.',
                style: TextStyle(color: muted, fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _wishlistCard(
    BuildContext context,
    WishlistItem item,
    String? category,
    bool isDark,
  ) {
    final foreground = isDark ? AppColors.white : AppColors.black;
    final muted = isDark ? Colors.white60 : Colors.grey[600];
    final surface = isDark ? AppColors.darkGrey : Colors.white;

    return Card(
      color: surface,
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Material(
                  color: isDark ? AppColors.nearBlack : AppColors.offWhite,
                  child: InkWell(
                    onTap: () => context.go('/product/${item.productId}'),
                    child: ProductImage(
                      image: item.image,
                      fit: BoxFit.contain,
                      backgroundColor: isDark
                          ? AppColors.nearBlack
                          : AppColors.offWhite,
                      iconColor: isDark ? Colors.white38 : Colors.grey[500],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: surface.withValues(alpha: 0.96),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Remove ${item.productName} from wishlist',
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        try {
                          await context
                              .read<WishlistProvider>()
                              .removeFromWishlist(item.productId);
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Unable to remove item: $error'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.favorite,
                        size: 19,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null) ...[
                    Text(
                      category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          CurrencyUtil.format(item.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () =>
                            context.go('/product/${item.productId}'),
                        style: TextButton.styleFrom(
                          foregroundColor: foreground,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('VIEW'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyWishlist(BuildContext context, bool isDark) {
    final foreground = isDark ? AppColors.white : AppColors.black;
    final muted = isDark ? Colors.white60 : Colors.grey[600];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGrey : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 46,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your wishlist is empty',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save your favorite pieces while browsing and find them here whenever you are ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => context.go('/shop'),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text('BROWSE THE COLLECTION'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: foreground,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
