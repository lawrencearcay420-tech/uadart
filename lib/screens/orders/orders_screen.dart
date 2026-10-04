import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/backgrounds/page_background.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/currency.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/data/models/order.dart';
import 'package:clothingapp/providers/order_provider.dart';
import 'package:clothingapp/providers/auth_provider.dart';
import 'package:clothingapp/widgets/common/app_back_button.dart';
import 'package:clothingapp/widgets/common/loading_state.dart';
import 'package:intl/intl.dart';
import 'package:clothingapp/widgets/common/product_image.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.getHorizontalPadding(context);

    if (orderProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? AppColors.white : AppColors.black,
          leading: const AppBackButton(),
          title: const Text('Orders'),
        ),
        body: const LoadingState(message: 'Loading orders...'),
      );
    }

    final orders =
        orderProvider
            .getOrdersForCustomer(auth.currentUser?.email ?? '')
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.white : AppColors.black,
        leading: const AppBackButton(),
        title: const Text('My Orders'),
      ),
      body: PageBackground(
        intensity: 0.25,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 88, padding, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order history',
                              style: TextStyle(
                                color: isDark ? AppColors.white : AppColors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Review the items and status of your purchases.',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (orders.isEmpty)
                    _emptyOrdersCard(context, isDark)
                  else
                    ...orders.map(
                      (order) => _orderCard(context, order, isDark),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyOrdersCard(BuildContext context, bool isDark) {
    final foreground = isDark ? AppColors.white : AppColors.black;
    final muted = isDark ? Colors.white60 : Colors.grey[600];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGrey : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 30,
              color: foreground,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No orders yet',
            style: TextStyle(
              color: foreground,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you place an order, its items, status, and total will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => context.go('/shop'),
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: const Text('BROWSE PRODUCTS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: foreground,
              side: BorderSide(
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
    );
  }

  Widget _orderCard(BuildContext context, Order order, bool isDark) {
    final itemCount = order.items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final surface = isDark ? AppColors.darkGrey : Colors.white;
    final foreground = isDark ? AppColors.white : AppColors.black;

    return Card(
      color: surface,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: foreground,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(order.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      order.status,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 64,
                        height: 72,
                        child: ProductImage(
                          image: item.image,
                          fit: BoxFit.contain,
                          backgroundColor: isDark
                              ? Colors.white10
                              : Colors.grey[100],
                          iconColor: isDark
                              ? Colors.white38
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Size ${item.size} · Qty ${item.quantity}',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      CurrencyUtil.format(item.totalPrice),
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.paymentMethod,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  'TOTAL  ${CurrencyUtil.format(order.total)}',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.packed:
        return Colors.indigo;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}
