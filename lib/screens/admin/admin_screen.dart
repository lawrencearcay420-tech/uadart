import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/backgrounds/page_background.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/providers/auth_provider.dart';
import 'package:clothingapp/providers/product_provider.dart';
import 'package:clothingapp/data/models/product.dart';
import 'package:clothingapp/widgets/common/empty_state.dart';
import 'package:clothingapp/widgets/common/app_back_button.dart';
import 'package:clothingapp/widgets/common/product_image.dart';
import 'package:clothingapp/screens/admin/product_form_dialog.dart';
import 'package:clothingapp/screens/admin/stock_adjustment_dialog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

enum AdminTab { dashboard, products, inventory, orders, sales }

class _AdminScreenState extends State<AdminScreen> {
  AdminTab _currentTab = AdminTab.dashboard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isAdmin) {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.read<AuthProvider>();
    final isAdmin = auth.isAdmin;

    if (!isAdmin) {
      return Scaffold(
        body: Center(
          child: Text(
            'Admin access required',
            style: TextStyle(color: isDark ? AppColors.white : AppColors.black),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.white : AppColors.black,
        leading: const AppBackButton(),
        title: const Text('Admin Dashboard'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: PageBackground(
        intensity: 0.25,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) _buildSidebar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 220,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          ...AdminTab.values.map((tab) {
            final isSelected = _currentTab == tab;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: isSelected ? Colors.black : Colors.transparent,
                child: Icon(
                  _tabIcon(tab),
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.grey[600]),
                ),
              ),
              title: Text(
                _tabLabel(tab),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isDark
                      ? (isSelected ? AppColors.white : Colors.white70)
                      : (isSelected ? AppColors.black : Colors.grey[600]),
                ),
              ),
              onTap: () => setState(() => _currentTab = tab),
            );
          }),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: const Icon(Icons.logout, size: 16),
            title: const Text('Logout', style: TextStyle(fontSize: 13)),
            onTap: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
    );
  }

  IconData _tabIcon(AdminTab tab) {
    switch (tab) {
      case AdminTab.dashboard:
        return Icons.dashboard;
      case AdminTab.products:
        return Icons.shopping_bag;
      case AdminTab.inventory:
        return Icons.inventory_2;
      case AdminTab.orders:
        return Icons.receipt_long;
      case AdminTab.sales:
        return Icons.bar_chart;
    }
  }

  String _tabLabel(AdminTab tab) {
    switch (tab) {
      case AdminTab.dashboard:
        return 'Dashboard';
      case AdminTab.products:
        return 'Products';
      case AdminTab.inventory:
        return 'Inventory';
      case AdminTab.orders:
        return 'Orders';
      case AdminTab.sales:
        return 'Sales';
    }
  }

  Widget _buildContent() {
    final padding = Responsive.getHorizontalPadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tabLabel(_currentTab),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          if (_currentTab == AdminTab.dashboard) _buildDashboard(),
          if (_currentTab == AdminTab.products) _buildProductsList(),
          if (_currentTab == AdminTab.inventory) _buildInventory(),
          if (_currentTab == AdminTab.orders) _buildOrders(),
          if (_currentTab == AdminTab.sales) _buildSales(),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final stats = [
      {'label': 'TOTAL SALES', 'value': '₱456,780', 'icon': Icons.attach_money},
      {'label': 'TOTAL ORDERS', 'value': '1,234', 'icon': Icons.receipt_long},
      {'label': 'PRODUCTS', 'value': '8', 'icon': Icons.shopping_bag},
      {'label': 'LOW STOCK', 'value': '3', 'icon': Icons.warning},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.map((stat) {
        return SizedBox(
          width: 200,
          child: Card(
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(stat['icon'] as IconData, size: 24, color: Colors.black),
                  const SizedBox(height: 8),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductsList() {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${products.length} ${products.length == 1 ? 'product' : 'products'} in the catalog',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _editProduct(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add product'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (productProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (products.isEmpty)
          const EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'No products to manage',
            message: 'Add a product to make it available in the shop.',
          )
        else
          ...products.map(
            (product) => Card(
              color: isDark ? AppColors.darkGrey : Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: SizedBox(
                    width: 58,
                    height: 64,
                    child: ProductImage(
                      image: product.image,
                      backgroundColor: isDark
                          ? AppColors.nearBlack
                          : AppColors.offWhite,
                    ),
                  ),
                ),
                title: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${product.category} · ${product.sku} · ${product.stock} in stock',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                     IconButton(
                       tooltip: 'Edit ${product.name}',
                       onPressed: () => _editProduct(product),
                       icon: const Icon(Icons.edit_outlined),
                     ),
                     IconButton(
                       tooltip: 'Adjust stock for ${product.name}',
                       onPressed: () => _adjustStock(product),
                       icon: const Icon(Icons.inventory_2_outlined),
                     ),
                     IconButton(
                       tooltip: 'Delete ${product.name}',
                       onPressed: () => _deleteProduct(product),
                       icon: const Icon(
                         Icons.delete_outline,
                         color: AppColors.error,
                       ),
                     ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _editProduct([Product? product]) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
    if (result == null || !mounted) return;

    final provider = context.read<ProductProvider>();
    final duplicateSku = provider.products.any(
      (existing) =>
          existing.sku.toLowerCase() == result.sku.toLowerCase() &&
          existing.id != result.id,
    );
    if (duplicateSku) {
      _showAdminMessage('A product with this SKU already exists.');
      return;
    }

    try {
      if (product == null) {
        await provider.addProduct(result);
      } else {
        await provider.updateProduct(result);
      }
      if (mounted) {
        _showAdminMessage(
          product == null ? 'Product added to the catalog.' : 'Product updated.',
        );
      }
    } catch (error) {
      if (mounted) _showAdminMessage('Unable to save product: $error');
    }
  }

  Future<void> _adjustStock(Product product) async {
    final newInventory = await showDialog<Map<String, int>>(
      context: context,
      builder: (_) => StockAdjustmentDialog(product: product),
    );
    if (newInventory == null || !mounted) return;

    try {
      await context.read<ProductProvider>().adjustStock(product.id, newInventory);
      if (mounted) _showAdminMessage('Stock updated for ${product.name}.');
    } catch (error) {
      if (mounted) _showAdminMessage('Unable to update stock: $error');
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          '“${product.name}” will be removed from the customer catalog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<ProductProvider>().deleteProduct(product.id);
      if (mounted) _showAdminMessage('Product deleted.');
    } catch (error) {
      if (mounted) _showAdminMessage('Unable to delete product: $error');
    }
  }

  void _showAdminMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildInventory() {
    return const Center(
      child: EmptyState(
        icon: Icons.inventory_2,
        title: 'No inventory alerts',
        message: 'All products are fully stocked.',
      ),
    );
  }

  Widget _buildOrders() {
    return const Center(
      child: EmptyState(
        icon: Icons.receipt_long,
        title: 'No orders',
        message: 'No orders to process yet.',
      ),
    );
  }

  Widget _buildSales() {
    return const Center(
      child: EmptyState(
        icon: Icons.bar_chart,
        title: 'No sales data',
        message: 'Sales data will appear here once orders are placed.',
      ),
    );
  }
}
