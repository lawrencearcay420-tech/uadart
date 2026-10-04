import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/backgrounds/page_background.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/constants/app_spacing.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/providers/auth_provider.dart';
import 'package:clothingapp/providers/product_provider.dart';
import 'package:clothingapp/widgets/common/glass_panel.dart';
import 'package:clothingapp/widgets/product/product_card.dart';
import 'package:clothingapp/widgets/common/show_product_search.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: Responsive.isDesktop(context)
            ? _buildDesktopActions(context, isAuthenticated)
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Browse and search products',
                  onPressed: () => _openProductSearch(context),
                ),
                IconButton(
                  icon: Icon(isAuthenticated ? Icons.logout : Icons.login),
                  tooltip: isAuthenticated ? 'Log out' : 'Log in',
                  onPressed: () => _handleAuthAction(context, isAuthenticated),
                ),
                const SizedBox(width: 8),
              ],
      ),
      body: PageBackground(
        intensity: 1.0,
        child: _buildContent(context, productProvider),
      ),
    );
  }

  List<Widget> _buildDesktopActions(
    BuildContext context,
    bool isAuthenticated,
  ) {
    return [
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _openProductSearch(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, size: 20),
                SizedBox(width: 4),
                Text('SEARCH'),
              ],
            ),
          ),
        ),
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          icon: const Icon(Icons.favorite_border, size: 22),
          onPressed: () => context.go('/wishlist'),
        ),
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, size: 22),
          onPressed: () => context.go('/cart'),
        ),
      ),
      TextButton.icon(
        onPressed: () => _handleAuthAction(context, isAuthenticated),
        icon: Icon(isAuthenticated ? Icons.logout : Icons.login, size: 18),
        label: Text(isAuthenticated ? 'LOG OUT' : 'LOG IN'),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      const SizedBox(width: 16),
    ];
  }

  Future<void> _handleAuthAction(
    BuildContext context,
    bool isAuthenticated,
  ) async {
    if (!isAuthenticated) {
      context.go('/login');
      return;
    }

    await context.read<AuthProvider>().logout();
    if (context.mounted) context.go('/login');
  }

  Future<void> _openProductSearch(BuildContext context) async {
    final query = await showProductSearch(context);
    if (query == null || !context.mounted) return;
    context.go('/shop?search=${Uri.encodeQueryComponent(query)}');
  }

  Widget _buildContent(BuildContext context, ProductProvider productProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategories(context),
          _buildHeroSection(context),
          const SizedBox(height: AppSpacing.xxl),
          _buildSection(
            context,
            'Featured Collection',
            productProvider.isLoading ? null : productProvider.featuredProducts,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSection(
            context,
            'Best Sellers',
            productProvider.isLoading ? null : productProvider.bestSellers,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildNewsletter(context),
          const SizedBox(height: AppSpacing.xxl),
          _buildBrandStory(context),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isCompact =
        MediaQuery.sizeOf(context).height < 700 || Responsive.isMobile(context);
    final headingSize = isCompact ? 32.0 : 42.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage('assets/logo.jpeg'),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.getHorizontalPadding(context),
          vertical: isCompact ? 24 : 64,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MINIMAL PIECES.',
              style: TextStyle(
                fontSize: headingSize,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              'MAXIMUM PRESENCE.',
              style: TextStyle(
                fontSize: headingSize,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            SizedBox(height: isCompact ? 10 : 16),
            Text(
              'Under Asawa Clothing',
              style: TextStyle(
                fontSize: isCompact ? 20 : 24,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: isCompact ? 10 : 16),
            Text(
              'Thoughtfully designed pieces for everyday movement.',
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            SizedBox(height: isCompact ? 16 : 24),
            Row(
              children: [
                FilledButton(
                  onPressed: () => context.go('/shop'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SHOP COLLECTION',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => context.go('/shop'),
                  icon: const Icon(Icons.arrow_downward, size: 16),
                  label: const Text(
                    'DISCOVER THE BRAND',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Product>? products, {
    required bool isDark,
  }) {
    final padding = Responsive.getHorizontalPadding(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.scaleFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (products == null)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.getGridColumns(context),
                childAspectRatio: Responsive.getProductCardAspectRatio(context),
                crossAxisSpacing: Responsive.scalePadding(context, 16),
                mainAxisSpacing: Responsive.scalePadding(context, 16),
              ),
              itemCount: 6,
              itemBuilder: (context, index) =>
                  GlassPanel(borderRadius: 16, child: const SizedBox.expand()),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.getGridColumns(context),
                childAspectRatio: Responsive.getProductCardAspectRatio(context),
                crossAxisSpacing: Responsive.scalePadding(context, 16),
                mainAxisSpacing: Responsive.scalePadding(context, 16),
              ),
              itemCount: products.length.clamp(0, 8),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.go('/product/${product.id}'),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ['Jackets', 'T-Shirts', 'Pants', 'Accessories'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getHorizontalPadding(context),
      ),
      margin: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + kToolbarHeight,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHOP BY CATEGORY',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _categoryChip(context, cat),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(BuildContext context, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      label: Text(
        name,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.black,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      onSelected: (_) =>
          context.go('/shop?category=${Uri.encodeQueryComponent(name)}'),
      backgroundColor: isDark ? AppColors.darkGrey : AppColors.white,
      selected: false,
      side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    );
  }

  Widget _buildNewsletter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getHorizontalPadding(context),
      ),
      child: GlassPanel(
        borderRadius: 20,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE UA LETTER',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New pieces. Quiet launches. Behind the collection.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'theunderasawa.com',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandStory(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getHorizontalPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WE BELIEVE CLOTHING SHOULD FEEL LIKE YOU.',
            style: TextStyle(
              fontSize: isDark ? 22 : 24,
              fontWeight: FontWeight.w300,
              height: 1.2,
              color: isDark ? Colors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Under Asawa is built around considered pieces, quiet confidence and everyday movement.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
