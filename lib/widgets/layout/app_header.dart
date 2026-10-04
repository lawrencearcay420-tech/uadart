import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/providers/theme_provider.dart';
import 'package:clothingapp/widgets/common/show_product_search.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppHeader({super.key, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(context),
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      actions: _buildActions(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    if (isDesktop) {
      return Row(
        children: [
          const Text(
            'Under Asawa',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(width: 32),
          _buildDesktopNavLink(context, 'SHOP', '/shop'),
          _buildDesktopNavLink(context, 'NEW ARRIVALS', '/shop'),
          _buildDesktopNavLink(context, 'CLOTHING', '/shop'),
          _buildDesktopNavLink(context, 'ACCESSORIES', '/shop'),
          _buildDesktopNavLink(context, 'JOURNAL', '/shop'),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      );
    }
    return Text(
      title.isEmpty ? 'Under Asawa' : title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    if (isDesktop) {
      return [
        _desktopAction(context, Icons.search, () => _showSearch(context)),
        _desktopAction(context, Icons.favorite_border, () {}),
        _themeToggle(context),
        _desktopAction(
          context,
          Icons.shopping_bag_outlined,
          () => _openCart(context),
        ),
        const SizedBox(width: 16),
      ];
    }
    return [
      if (title.isNotEmpty && title != 'Under Asawa')
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearch(context),
        ),
      _themeToggle(context),
      IconButton(
        icon: const Icon(Icons.shopping_bag_outlined),
        onPressed: () => _openCart(context),
      ),
    ];
  }

  Widget _buildDesktopNavLink(
    BuildContext context,
    String label,
    String route,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _desktopAction(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: IconButton(icon: Icon(icon, size: 20), onPressed: onTap),
    );
  }

  Future<void> _showSearch(BuildContext context) async {
    final query = await showProductSearch(context);
    if (query == null || !context.mounted) return;
    context.go('/shop?search=${Uri.encodeQueryComponent(query)}');
  }

   void _openCart(BuildContext context) {
    context.go('/checkout');
  }

  Widget _themeToggle(BuildContext context) {
    final theme = context.watch<AppThemeProvider>();
    final isDark = theme.isDark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: IconButton(
        tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            key: ValueKey<bool>(isDark),
            size: 20,
          ),
        ),
        onPressed: () => theme.toggleTheme(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
